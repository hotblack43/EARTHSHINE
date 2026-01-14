#!/usr/bin/env python3
from __future__ import annotations

import os
import signal
import subprocess
import glob
from pathlib import Path
from typing import List, Tuple

import numpy as np
from astropy.io import fits


# --------- CONFIG ---------
GO_PRO = "go.pro"                 # run with: gdl go.pro
JD_FILE = "JDtouseforSYNTH"       # list of JDs to process (one per line)
USETHIS_JD_FILE = "usethisJD"     # IDL reads this

# Where IDL/GDL writes its OUTPUT products (absolute path is OK)
OUTPUT_DIR = Path("OUTPUT")

# Where THIS script should write the stacked cubes
STACK_DIR = OUTPUT_DIR / "/dmidata/projects/nckf/earthshine/WORKSHOP/EARTHSHINE/OUTPUT/CUBES"
STACK_DIR = OUTPUT_DIR / "CUBES"

OUT_PATTERN = "synthetic_stack_JD{jdtag}.fits"

AUX_DIR = OUTPUT_DIR / "LONLAT_AND_ANGLES_IMAGES"

# --------------------------


def rename_layer_labels(names: List[str]) -> List[str]:
    out = []
    for nm in names:
        if nm == "lonlat_layer0":
            out.append("lon_layer")
        elif nm == "lonlat_layer1":
            out.append("lat_layer")
        elif nm == "angles_layer0":
            out.append("angle_to_sun")
        elif nm == "angles_layer1":
            out.append("angle_to_geocenter")
        elif nm == "angles_layer2":
            out.append("angle_to_observer")
        else:
            out.append(nm)
    return out


def jd_tag(jd: float) -> str:
    # Matches your filenames, e.g. 2455748.7576445 (7 decimals)
    return f"{jd:.7f}"


def write_usethis_jd(jd: float) -> None:
    Path(USETHIS_JD_FILE).write_text(f"{jd:.7f}\n", encoding="utf-8")


def run_gdl_go() -> None:
    """
    Run: gdl go.pro
    Robust against Ctrl+C leaving orphaned gdl processes.
    """
    cmd = ["gdl", GO_PRO]
    proc = subprocess.Popen(
        cmd,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        start_new_session=True,
    )
    try:
        stdout, stderr = proc.communicate()
    except KeyboardInterrupt:
        try:
            os.killpg(proc.pid, signal.SIGTERM)
        except Exception:
            pass
        try:
            os.killpg(proc.pid, signal.SIGKILL)
        except Exception:
            pass
        raise

    if proc.returncode != 0:
        raise RuntimeError(
            "GDL failed.\n"
            f"Command: {cmd}\n"
            f"Return code: {proc.returncode}\n"
            f"STDOUT:\n{stdout}\n"
            f"STDERR:\n{stderr}\n"
        )


def find_one(pattern: str) -> Path:
    """
    Find the first file matching a glob pattern.
    Uses glob.glob() so absolute patterns work on Python 3.13+.
    """
    hits = sorted(glob.glob(pattern))
    if not hits:
        raise FileNotFoundError(f"No files matched: {pattern}")
    return Path(hits[0])


def read_fits_any(path: Path) -> np.ndarray:
    """
    Read FITS primary HDU data as float32.
    Can be 2D or 3D (layered cube).
    """
    with fits.open(path) as hdul:
        data = hdul[0].data
        if data is None:
            raise ValueError(f"No data in {path}")
        return np.asarray(data, dtype=np.float32)


def to_layers(arr: np.ndarray, name_prefix: str) -> Tuple[List[np.ndarray], List[str]]:
    """
    Convert 2D or 3D array into a list of 2D layers plus layer names.
    FITS cubes should come in as (nlayer, ny, nx) in numpy here.
    """
    if arr.ndim == 2:
        return [arr], [name_prefix]
    if arr.ndim == 3:
        layers = [arr[k, :, :] for k in range(arr.shape[0])]
        names = [f"{name_prefix}_layer{k}" for k in range(arr.shape[0])]
        return layers, names
    raise ValueError(f"Unsupported array ndim={arr.ndim} for {name_prefix}: shape={arr.shape}")


def stack_and_write(jd: float) -> Path:
    jdstr = jd_tag(jd)

    # ---- locate files by JD (use OUTPUT_DIR consistently) ----
    f_ideal0 = find_one(str(OUTPUT_DIR / f"IDEAL/ideal_LunarImg_SCA_*0p000*JD*{jdstr}*.fit*"))
    f_ideal1 = find_one(str(OUTPUT_DIR / f"IDEAL/ideal_LunarImg_SCA_*1p000*JD*{jdstr}*.fit*"))
#   f_lonlat = find_one(str(OUTPUT_DIR / f"lonlatSELimage_JD{jdstr}.fit*"))
#   f_angles = find_one(str(OUTPUT_DIR / f"Angles_JD{jdstr}.fit*"))
    f_lonlat = find_one(str(AUX_DIR / f"lonlatSELimage_JD{jdstr}.fit*"))
    f_angles = find_one(str(AUX_DIR / f"Angles_JD{jdstr}.fit*"))

    f_sunmsk = find_one(str(OUTPUT_DIR / f"SUNMASK/*{jdstr}*.fit*"))

    # ---- read arrays ----
    a_ideal0 = read_fits_any(f_ideal0)
    a_ideal1 = read_fits_any(f_ideal1)
    a_lonlat = read_fits_any(f_lonlat)
    a_angles = read_fits_any(f_angles)
    a_sunmsk = read_fits_any(f_sunmsk)

    # ---- build layers in desired order ----
    layers: List[np.ndarray] = []
    names: List[str] = []

    l, n = to_layers(a_ideal0, "ideal_sca0"); layers += l; names += n
    l, n = to_layers(a_ideal1, "ideal_sca1"); layers += l; names += n
    l, n = to_layers(a_lonlat, "lonlat");     layers += l; names += n
    l, n = to_layers(a_angles, "angles");     layers += l; names += n
    l, n = to_layers(a_sunmsk, "sunmask");    layers += l; names += n

    # Rename layer labels to your preferred names
    names = rename_layer_labels(names)

    # ---- sanity: all layers 2D and same shape ----
    shape = layers[0].shape
    for nm, lay in zip(names, layers):
        if lay.ndim != 2:
            raise ValueError(f"Layer {nm} not 2D: shape={lay.shape}")
        if lay.shape != shape:
            raise ValueError(f"Shape mismatch: {nm}={lay.shape} vs {names[0]}={shape}")

    cube = np.stack(layers, axis=0).astype(np.float32, copy=False)

    # ---- write output into STACK_DIR (under OUTPUT_DIR) ----
    STACK_DIR.mkdir(parents=True, exist_ok=True)
    out = STACK_DIR / OUT_PATTERN.format(jdtag=jdstr)

    hdu = fits.PrimaryHDU(cube)
    hdr = hdu.header
    hdr["JD"] = (float(jd), "Julian Date for this synthetic stack")
    hdr["NLAYER"] = (int(cube.shape[0]), "Number of layers in cube")
    for i, nm in enumerate(names, start=1):
        hdr[f"LAYER{i:02d}"] = nm

    hdu.writeto(out, overwrite=True)
    return out


def iter_jds(path: Path):
    with path.open("r", encoding="utf-8", errors="replace") as f:
        for raw in f:
            s = raw.strip()
            if not s or s.startswith("#") or s.startswith(";"):
                continue
            s = s.split("#")[0].split(";")[0].strip()
            if not s:
                continue
            yield float(s)


def main() -> int:
    jd_path = Path(JD_FILE)
    if not jd_path.exists():
        print(f"ERROR: cannot find {JD_FILE} in {Path.cwd()}")
        return 2

    try:
        for jd in iter_jds(jd_path):
            print(f"\n=== JD {jd_tag(jd)} ===")
            write_usethis_jd(jd)
            run_gdl_go()
            out = stack_and_write(jd)
            print(f"Wrote {out}")

    except KeyboardInterrupt:
        print("\nInterrupted by user.")
        return 130

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

