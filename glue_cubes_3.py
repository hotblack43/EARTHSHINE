#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
import glob
from pathlib import Path
from datetime import datetime
from typing import Optional, Tuple, List, Iterable

import numpy as np
from astropy.io import fits


# ---------------- CONFIG DEFAULTS ----------------
DEFAULT_OBS_DIR = Path("CENTERED")  # change or pass --obs-dir
DEFAULT_SYN_DIR = Path("OUTPUT/CUBES")
DEFAULT_OUT_DIR = Path("OUTPUT/COMBINED")
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


def flip_lr(cube: np.ndarray) -> np.ndarray:
    """
    Flip left-right (x-axis) for a 3D cube shaped (nlayer, ny, nx).
    """
    # last axis is X
    return cube[..., ::-1].copy()


def _layer_names_from_header(hdr: fits.Header, n: int, prefixes: Iterable[str], fallback_prefix: str) -> List[str]:
    """
    Try to extract per-layer names from header keywords.

    Looks for keys like:
      LAYER01..LAYERnn
      OBS01..OBSn
      SYN01..SYNn
    (depending on prefixes provided)

    Returns a list of length n. Missing keys fall back to "<fallback_prefix><index>".
    """
    out: List[str] = []
    for i in range(1, n + 1):
        val: Optional[str] = None
        for p in prefixes:
            k = f"{p}{i:02d}"
            if k in hdr:
                val = str(hdr[k]).strip()
                break
        if val is None or val == "":
            val = f"{fallback_prefix}{i-1}"
        out.append(val)
    return out


def get_obs_layer_names(obs_hdr: fits.Header, n_obs: int) -> List[str]:
    # Try common patterns; fall back to generic.
    return _layer_names_from_header(
        obs_hdr,
        n_obs,
        prefixes=("LAYER", "OBS"),
        fallback_prefix="obs_layer",
    )


def get_syn_layer_names(syn_hdr: fits.Header, n_syn: int) -> List[str]:
    return _layer_names_from_header(
        syn_hdr,
        n_syn,
        prefixes=("LAYER", "SYN"),
        fallback_prefix="syn_layer",
    )


def merge_obs_header_into(hdr_base: fits.Header, obs_hdr: fits.Header) -> fits.Header:
    """
    Merge observational header into hdr_base while avoiding structural FITS keywords
    that must match the combined data.

    Keeps essentially all observational metadata.
    """
    # Keywords that are structural or routinely auto-managed for the PrimaryHDU
    skip_exact = {
        "SIMPLE", "BITPIX", "NAXIS", "EXTEND",
        "BSCALE", "BZERO",
        "DATAMIN", "DATAMAX",
    }

    # Also skip NAXIS1/2/3 etc
    def should_skip(key: str) -> bool:
        if key in skip_exact:
            return True
        if key.startswith("NAXIS"):
            return True
        # We'll handle HISTORY/COMMENT explicitly (but we don't want to lose them)
        if key in {"HISTORY", "COMMENT"}:
            return True
        return False

    # Copy/overwrite cards from obs_hdr into hdr_base
    for card in obs_hdr.cards:
        key = card.keyword
        if key is None or key == "":
            continue
        if should_skip(key):
            continue
        # Overwrite or insert
        hdr_base[key] = (card.value, card.comment)

    # Preserve observational HISTORY/COMMENT too
    # (append them so we don't lose provenance)
    for h in obs_hdr.get("HISTORY", []):
        hdr_base.add_history(str(h))
    for c in obs_hdr.get("COMMENT", []):
        hdr_base.add_comment(str(c))

    return hdr_base


def parse_layer_desc_from_string(layer_desc: str) -> List[str]:
    """
    Parse a comma-separated list of layer descriptions.

    Example:
      "obs01,obs02,obs03,obs04,obs05,obs06, syn01,syn02,syn03,syn04,syn05"
    """
    # Split on commas, strip whitespace. Do NOT discard empty items silently.
    raw = [x.strip() for x in layer_desc.split(",")]
    out: List[str] = []
    for i, item in enumerate(raw):
        if item == "":
            raise ValueError(f"--layer-desc contains an empty entry at position {i+1}.")
        out.append(item)
    return out


def parse_layer_desc_from_file(path: Path) -> List[str]:
    """
    Parse a layer description file with one description per line.

    - Blank lines are ignored
    - Lines beginning with '#' are ignored
    - Everything else is used verbatim (stripped at both ends)
    """
    if not path.exists():
        raise FileNotFoundError(f"--layer-desc-file not found: {path}")

    lines = path.read_text(encoding="utf-8").splitlines()
    out: List[str] = []
    for ln in lines:
        s = ln.strip()
        if s == "":
            continue
        if s.startswith("#"):
            continue
        out.append(s)
    return out


def choose_layer_descriptions(
    n_obs: int,
    n_syn: int,
    obs_hdr: fits.Header,
    syn_hdr: fits.Header,
    user_layer_desc: Optional[str],
    user_layer_desc_file: Optional[Path],
) -> Tuple[List[str], List[str], List[str]]:
    """
    Returns:
      obs_names (length n_obs),
      syn_names (length n_syn),
      all_names (length n_obs+n_syn)

    If user_layer_desc or user_layer_desc_file is provided, it overrides header-derived names.
    Otherwise, it uses header-derived names.
    """
    n_tot = int(n_obs + n_syn)

    if user_layer_desc is not None and str(user_layer_desc).strip() != "":
        all_names = parse_layer_desc_from_string(str(user_layer_desc).strip())
        if len(all_names) != n_tot:
            raise ValueError(
                f"--layer-desc must contain exactly {n_tot} entries (n_obs={n_obs}, n_syn={n_syn}), "
                f"but it contains {len(all_names)} entries."
            )
        obs_names = list(all_names[:n_obs])
        syn_names = list(all_names[n_obs:])
        return obs_names, syn_names, all_names

    if user_layer_desc_file is not None:
        all_names = parse_layer_desc_from_file(user_layer_desc_file)
        if len(all_names) != n_tot:
            raise ValueError(
                f"--layer-desc-file must contain exactly {n_tot} non-comment, non-blank lines "
                f"(n_obs={n_obs}, n_syn={n_syn}), but it contains {len(all_names)} lines."
            )
        obs_names = list(all_names[:n_obs])
        syn_names = list(all_names[n_obs:])
        return obs_names, syn_names, all_names

    # Default behaviour: derive from headers
    obs_names = get_obs_layer_names(obs_hdr, n_obs)
    syn_names = get_syn_layer_names(syn_hdr, n_syn)
    all_names = obs_names + syn_names
    return obs_names, syn_names, all_names


def write_combined(
    out_path: Path,
    obs_cube: np.ndarray,
    synth_cube: np.ndarray,
    obs_path: Path,
    synth_path: Path,
    obs_hdr: fits.Header,
    synth_hdr: fits.Header,
    flip_which: str,
    user_layer_desc: Optional[str],
    user_layer_desc_file: Optional[Path],
) -> None:
    if not (is_cube(obs_cube) and is_cube(synth_cube)):
        raise ValueError(f"Expected cubes: obs {obs_cube.shape}, synth {synth_cube.shape}")

    if obs_cube.shape[1:] != synth_cube.shape[1:]:
        raise ValueError(
            f"Shape mismatch: obs {obs_cube.shape} vs synth {synth_cube.shape} "
            f"for {obs_path.name} + {synth_path.name}"
        )

    # Optional flip
    flip_which = flip_which.lower().strip()
    if flip_which == "obs":
        obs_cube = flip_lr(obs_cube)
    elif flip_which == "syn":
        synth_cube = flip_lr(synth_cube)
    elif flip_which in ("none", ""):
        pass
    else:
        raise ValueError(f"Invalid --flip value: {flip_which} (use none|obs|syn)")

    combined = np.concatenate([obs_cube, synth_cube], axis=0).astype(np.float32, copy=False)

    n_obs = int(obs_cube.shape[0])
    n_syn = int(synth_cube.shape[0])
    n_tot = int(combined.shape[0])

    # Build a sane base header from the combined data (auto-sets NAXIS*, BITPIX, etc.)
    hdu = fits.PrimaryHDU(combined)
    hdr = hdu.header

    # Merge observational header metadata (retain all obs info, except structural keys)
    hdr = merge_obs_header_into(hdr, obs_hdr)

    # Add our provenance and bookkeeping
    hdr.add_history(f"Combined on {nowstamp()}")
    hdr["OBSFILE"] = (obs_path.name, "Observed cube source file")
    hdr["SYNFILE"] = (synth_path.name, "Synthetic cube source file")
    hdr["NOBS"] = (n_obs, "Number of observed layers")
    hdr["NSYN"] = (n_syn, "Number of synthetic layers")
    hdr["NLAYER"] = (n_tot, "Total number of layers in combined cube")
    hdr["FLIPLR"] = (flip_which, "Left-right flip applied to: none|obs|syn")

    # Layer names: either user-supplied array, or combined list derived from headers
    obs_names, syn_names, all_names = choose_layer_descriptions(
        n_obs=n_obs,
        n_syn=n_syn,
        obs_hdr=obs_hdr,
        syn_hdr=synth_hdr,
        user_layer_desc=user_layer_desc,
        user_layer_desc_file=user_layer_desc_file,
    )

    # Write combined list as LAYER01..LAYERnn
    for i, nm in enumerate(all_names, start=1):
        hdr[f"LAYER{i:02d}"] = (nm, "")

    # Also keep separate groupings (optional but handy)
    for i, nm in enumerate(obs_names, start=1):
        hdr[f"OBS{i:02d}"] = (nm, "")
    for i, nm in enumerate(syn_names, start=1):
        hdr[f"SYN{i:02d}"] = (nm, "")

    # Write
    fits.PrimaryHDU(combined, header=hdr).writeto(out_path, overwrite=True)


def main() -> int:
    import argparse

    ap = argparse.ArgumentParser(description="Glue observed FITS cubes to synthetic stacks by JD in filename.")
    ap.add_argument("--obs-dir", type=str, default=str(DEFAULT_OBS_DIR), help="Directory containing observed FITS cubes.")
    ap.add_argument("--syn-dir", type=str, default=str(DEFAULT_SYN_DIR), help="Directory containing synthetic stacks.")
    ap.add_argument("--out-dir", type=str, default=str(DEFAULT_OUT_DIR), help="Directory to write combined cubes.")
    ap.add_argument("--log", type=str, default=str(DEFAULT_LOGFILE), help="Warning log file path.")
    ap.add_argument("--obs-glob", type=str, default="*.fit*", help="Glob pattern for observed cubes within obs-dir.")
    ap.add_argument(
        "--flip",
        type=str,
        default="syn",
        choices=("none", "obs", "syn"),
        help="Flip left-right for either observed cube (obs) or synthetic cube (syn) before concatenation.",
    )

    # User-supplied layer descriptions (optional override)
    ap.add_argument(
        "--layer-desc",
        type=str,
        default=None,
        help=(
            "Optional override for layer descriptions. Comma-separated list with exactly NLAYER entries. "
            "If provided, overrides header-derived names. Example for 11 layers: "
            "\"obs1,obs2,obs3,obs4,obs5,obs6,syn1,syn2,syn3,syn4,syn5\""
        ),
    )
    ap.add_argument(
        "--layer-desc-file",
        type=str,
        default=None,
        help=(
            "Optional override for layer descriptions. Plain text file with one description per line. "
            "Blank lines ignored; lines starting with # ignored. Must contain exactly NLAYER lines. "
            "If provided, overrides header-derived names."
        ),
    )

    args = ap.parse_args()

    obs_dir = Path(args.obs_dir)
    syn_dir = Path(args.syn_dir)
    out_dir = Path(args.out_dir)
    logfile = Path(args.log)
    flip_which = str(args.flip)

    user_layer_desc: Optional[str] = args.layer_desc
    user_layer_desc_file: Optional[Path] = None
    if args.layer_desc_file is not None and str(args.layer_desc_file).strip() != "":
        user_layer_desc_file = Path(str(args.layer_desc_file).strip())

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

        try:
            obs_cube, obs_hdr = read_fits_data(obs_path)
            synth_cube, synth_hdr = read_fits_data(synth_path)

            if obs_cube.ndim != 3:
                raise ValueError(f"Observed is not a cube (ndim={obs_cube.ndim})")
            if synth_cube.ndim != 3:
                raise ValueError(f"Synthetic is not a cube (ndim={synth_cube.ndim})")

            out_path = out_dir / f"combined_JD{jd}_{obs_path.stem}.fits"
            write_combined(
                out_path,
                obs_cube,
                synth_cube,
                obs_path,
                synth_path,
                obs_hdr,
                synth_hdr,
                flip_which=flip_which,
                user_layer_desc=user_layer_desc,
                user_layer_desc_file=user_layer_desc_file,
            )

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

