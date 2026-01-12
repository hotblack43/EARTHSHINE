#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
import glob
from pathlib import Path
from datetime import datetime
from typing import Optional, Tuple, List

import numpy as np
from astropy.io import fits


# ---------------- CONFIG DEFAULTS ----------------
DEFAULT_OBS_DIR = Path("OBSERVED_STACKS")  # change or pass --obs-dir
DEFAULT_SYN_DIR = Path("/dmidata/projects/nckf/earthshine/WORKSHOP/OUTPUT/SYNTHSTACKS")
DEFAULT_OUT_DIR = Path("/dmidata/projects/nckf/earthshine/WORKSHOP/OUTPUT/COMBINED")
DEFAULT_LOGFILE = DEFAULT_OUT_DIR / "glue_warnings.log"

# JD pattern: look for something like 2455748.7576445 (7 decimals typical)
JD_REGEX = re.compile(r"(24\d{5}\.\d{3,10})")
# ------------------------------------------------


def nowstamp() -> str:
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def extract_jd_from_filename(path: Path) -> Optional[str]:
    """
    Returns JD string as found in filename (e.g. '2455748.7576445') or None.
    """
    m = JD_REGEX.search(path.name)
    if not m:
        return None
    return m.group(1)


def read_fits_data(path: Path) -> Tuple[np.ndarray, fits.Header]:
    with fits.open(path) as hdul:
        data = hdul[0].data
        hdr = hdul[0].header.copy()
    if data is None:
        raise ValueError(f"No data in {path}")
    arr = np.asarray(data, dtype=np.float32)
    return arr, hdr


def is_cube(arr: np.ndarray) -> bool:
    return arr.ndim == 3


def get_synth_layer_names(synth_hdr: fits.Header, n_syn: int) -> List[str]:
    """
    Synthetic stacks produced earlier have LAYER01.. in header.
    If missing, fall back to generic names.
    """
    names: List[str] = []
    for i in range(1, n_syn + 1):
        key = f"LAYER{i:02d}"
        if key in synth_hdr:
            names.append(str(synth_hdr[key]).strip())
        else:
            names.append(f"syn_layer{i-1}")
    return names


def write_combined(
    out_path: Path,
    obs_cube: np.ndarray,
    synth_cube: np.ndarray,
    obs_path: Path,
    synth_path: Path,
    synth_hdr: fits.Header,
) -> None:
    if not (is_cube(obs_cube) and is_cube(synth_cube)):
        raise ValueError(f"Expected cubes: obs {obs_cube.shape}, synth {synth_cube.shape}")

    if obs_cube.shape[1:] != synth_cube.shape[1:]:
        raise ValueError(
            f"Shape mismatch: obs {obs_cube.shape} vs synth {synth_cube.shape} "
            f"for {obs_path.name} + {synth_path.name}"
        )

    combined = np.concatenate([obs_cube, synth_cube], axis=0).astype(np.float32, copy=False)

    # Build header
    hdr = fits.Header()
    hdr["HISTORY"] = f"Combined on {nowstamp()}"
    hdr["OBSFILE"] = obs_path.name
    hdr["SYNFILE"] = synth_path.name
    hdr["NOBS"] = (int(obs_cube.shape[0]), "Number of observed layers")
    hdr["NSYN"] = (int(synth_cube.shape[0]), "Number of synthetic layers")
    hdr["NLAYER"] = (int(combined.shape[0]), "Total number of layers in combined cube")

    # Observed layer labels
    for i in range(1, obs_cube.shape[0] + 1):
        hdr[f"OBS{i:02d}"] = f"obs_layer{i-1}"

    # Synthetic layer labels (keep your nice names)
    syn_names = get_synth_layer_names(synth_hdr, int(synth_cube.shape[0]))
    for i, nm in enumerate(syn_names, start=1):
        hdr[f"SYN{i:02d}"] = nm

    fits.PrimaryHDU(combined, header=hdr).writeto(out_path, overwrite=True)


def log_line(logfile: Path, msg: str) -> None:
    logfile.parent.mkdir(parents=True, exist_ok=True)
    with logfile.open("a", encoding="utf-8") as f:
        f.write(msg.rstrip() + "\n")


def find_synth_for_jd(syn_dir: Path, jd: str) -> Optional[Path]:
    """
    Match your synthetic naming scheme:
      synthetic_stack_JD2455748.7576445.fits
    """
    patt = str(syn_dir / f"synthetic_stack_JD{jd}.fit*")
    hits = sorted(glob.glob(patt))
    if not hits:
        return None
    return Path(hits[0])


def main() -> int:
    import argparse

    ap = argparse.ArgumentParser(description="Glue observed FITS cubes to synthetic stacks by JD in filename.")
    ap.add_argument("--obs-dir", type=str, default=str(DEFAULT_OBS_DIR), help="Directory containing observed FITS cubes.")
    ap.add_argument("--syn-dir", type=str, default=str(DEFAULT_SYN_DIR), help="Directory containing synthetic stacks.")
    ap.add_argument("--out-dir", type=str, default=str(DEFAULT_OUT_DIR), help="Directory to write combined cubes.")
    ap.add_argument("--log", type=str, default=str(DEFAULT_LOGFILE), help="Warning log file path.")
    ap.add_argument("--obs-glob", type=str, default="*.fit*", help="Glob pattern for observed cubes within obs-dir.")
    args = ap.parse_args()

    obs_dir = Path(args.obs_dir)
    syn_dir = Path(args.syn_dir)
    out_dir = Path(args.out_dir)
    logfile = Path(args.log)

    out_dir.mkdir(parents=True, exist_ok=True)

    obs_files = sorted(obs_dir.glob(args.obs_glob))
    if not obs_files:
        print(f"ERROR: No observed files found in {obs_dir} matching {args.obs_glob}")
        return 2

    n_total = 0
    n_done = 0
    n_skipped = 0

    for obs_path in obs_files:
        n_total += 1

        jd = extract_jd_from_filename(obs_path)
        if jd is None:
            msg = f"[{nowstamp()}] WARNING: No JD found in observed filename: {obs_path.name} (skipping)"
            print(msg)
            log_line(logfile, msg)
            n_skipped += 1
            continue

        synth_path = find_synth_for_jd(syn_dir, jd)
        if synth_path is None:
            msg = f"[{nowstamp()}] WARNING: No synthetic stack for JD {jd} (observed {obs_path.name}) (skipping)"
            print(msg)
            log_line(logfile, msg)
            n_skipped += 1
            continue

        # Read both
        try:
            obs_cube, _ = read_fits_data(obs_path)
            synth_cube, synth_hdr = read_fits_data(synth_path)

            if obs_cube.ndim != 3:
                raise ValueError(f"Observed is not a cube (ndim={obs_cube.ndim})")
            if synth_cube.ndim != 3:
                raise ValueError(f"Synthetic is not a cube (ndim={synth_cube.ndim})")

            out_path = out_dir / f"combined_JD{jd}_{obs_path.stem}.fits"
            write_combined(out_path, obs_cube, synth_cube, obs_path, synth_path, synth_hdr)

            print(f"[{nowstamp()}] WROTE {out_path.name}")
            n_done += 1

        except Exception as e:
            msg = f"[{nowstamp()}] WARNING: Failed to combine JD {jd} for {obs_path.name}: {e}"
            print(msg)
            log_line(logfile, msg)
            n_skipped += 1

    print(f"\nDone. Total={n_total}  Combined={n_done}  Skipped={n_skipped}")
    print(f"Warnings log: {logfile}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

