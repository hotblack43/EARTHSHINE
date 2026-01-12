
#!/usr/bin/env python3
"""
make_twosynths.py

Python rewrite of your IDL setup:

IDL structure:
  PRO get_two_synethic_images, JD, im1, im2
    - write usethisJD
    - set single_scattering_albedo.dat = 0.0, run GDL script, read ItellYOUwantTHISimage.fits -> im1
    - set single_scattering_albedo.dat = 1.0, run GDL script, read ItellYOUwantTHISimage.fits -> im2
  END

  ; main routine:
  - open JDtouseforSYNTH
  - loop reading JD
"""

from __future__ import annotations

import sys
import os
import signal
import subprocess
from pathlib import Path
from typing import Tuple, Optional

import numpy as np
from astropy.io import fits
from astropy.time import Time
from astropy.coordinates import get_body_barycentric


# ---- Files / script names (match your IDL code) ----
GDL_SCRIPT = "go_get_particular_synthimage_42.pro"
JD_FILE = "JDtouseforSYNTH"

USETHIS_JD_FILE = "usethisJD"
ALBEDO_FILE = "single_scattering_albedo.dat"
OUTPUT_IMAGE_FITS = "ItellYOUwantTHISimage.fits"


def write_usethis_jd(jd: float, path: Path = Path(USETHIS_JD_FILE)) -> None:
    """
    IDL equivalent:
      openw,hjkl,'usethisJD'
      printf,hjkl,format='(f15.7)', JD(0)
      close,hjkl
    """
    path.write_text(f"{jd:15.7f}\n")


def write_albedo(albedo: float, path: Path = Path(ALBEDO_FILE)) -> None:
    """
    IDL equivalent:
      openw,hjkl,'single_scattering_albedo.dat'
      printf,hjkl, 0.0  (or 1.0)
      close,hjkl
    """
    path.write_text(f"{albedo}\n")


def run_gdl(script: str = GDL_SCRIPT) -> None:
    """
    Run the external GDL/IDL script in a way that can be interrupted cleanly.

    Why this exists:
      - Using subprocess.run(..., shell=True) makes Ctrl+C/kill unreliable because
        Python spawns a shell which then spawns gdl. Killing Python may leave gdl running.

    Implementation:
      - Start gdl in a new process session (new process group).
      - On KeyboardInterrupt, terminate the whole process group.
    """
    out = Path(OUTPUT_IMAGE_FITS)
    if out.exists():
        out.unlink()

    cmd = ["gdl", script]

    # Start a new session so we can kill the whole process group robustly.
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
        # Kill the entire process group (proc.pid is the PGID when start_new_session=True)
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
            "GDL call failed.\n"
            f"Command: {cmd}\n"
            f"Return code: {proc.returncode}\n"
            f"STDOUT:\n{stdout}\n"
            f"STDERR:\n{stderr}\n"
        )

    if not out.exists():
        raise FileNotFoundError(
            f"GDL call succeeded but did not produce expected file: {OUTPUT_IMAGE_FITS}"
        )


def read_fits_image(path: Path = Path(OUTPUT_IMAGE_FITS)) -> np.ndarray:
    """
    Reads the generated FITS image into a numpy array (float32).
    Works with NumPy 2.0+ (no invalid copy=False request).
    """
    with fits.open(path) as hdul:
        data = hdul[0].data
        if data is None:
            raise ValueError(f"No image data found in {path}")

        arr = np.asarray(data)  # may share memory or copy as needed
        if arr.dtype != np.float32:
            arr = arr.astype(np.float32, copy=False)  # converts if needed
        return arr


def old_read_fits_image(path: Path = Path(OUTPUT_IMAGE_FITS)) -> np.ndarray:
    """
    IDL equivalent:
      readfits,'ItellYOUwantTHISimage.fits',im1,/silent
    """
    with fits.open(path) as hdul:
        data = hdul[0].data
        if data is None:
            raise ValueError(f"No image data found in {path}")
        # NOTE: in NumPy 2.x, copy=False with dtype conversion can be strict.
        # Keep this for reference; use read_fits_image() above for robust behaviour.
        return np.array(data, dtype=np.float32, copy=False)


def get_two_synthetic_images(jd: float) -> Tuple[np.ndarray, np.ndarray]:
    """
    Python equivalent of:
      PRO get_two_synethic_images, JD, im1, im2
        ...
      END
    """
    print(f"get_two_synthetic_images has been given JD= {jd:15.7f}")

    # Provide JD to the external GDL/IDL logic
    write_usethis_jd(jd)

    # Albedo 0.0 -> im1
    write_albedo(0.0)
    print("hej hej 1")
    print(Path(ALBEDO_FILE).read_text().strip())
    run_gdl()
    im1 = read_fits_image()

    # Albedo 1.0 -> im2
    write_albedo(1.0)
    print("hej hej 2")
    print(Path(ALBEDO_FILE).read_text().strip())
    run_gdl()
    im2 = read_fits_image()

    return im1, im2


def illuminated_fraction_moon(jd: float) -> Optional[float]:
    """
    Rough physically-consistent illuminated fraction using barycentric geometry.

    Returns None on failure (e.g., ephemeris issues).
    """
    try:
        t = Time(jd, format="jd", scale="utc")

        # Vectors from Solar System barycenter to Earth and Moon
        r_earth = get_body_barycentric("earth", t)
        r_moon = get_body_barycentric("moon", t)
        r_sun = get_body_barycentric("sun", t)

        # Vectors as seen from the Moon:
        # Moon -> Sun and Moon -> Earth
        v_ms = r_sun - r_moon
        v_me = r_earth - r_moon

        # Phase angle = angle between Moon->Sun and Moon->Earth
        dot = (v_ms.x * v_me.x + v_ms.y * v_me.y + v_ms.z * v_me.z).to_value()
        ms = np.sqrt((v_ms.x**2 + v_ms.y**2 + v_ms.z**2).to_value())
        me = np.sqrt((v_me.x**2 + v_me.y**2 + v_me.z**2).to_value())
        cosang = float(dot / (ms * me))
        cosang = float(np.clip(cosang, -1.0, 1.0))
        phase = float(np.arccos(cosang))

        # Illuminated fraction
        k = (1.0 + np.cos(phase)) / 2.0
        return float(k)
    except Exception:
        return None


def stack_to_cube(im1: np.ndarray, im2: np.ndarray) -> np.ndarray:
    """
    Make a 2-layer cube intended to be written to FITS as:
      NAXIS1=512, NAXIS2=512, NAXIS3=2

    Astropy maps numpy shape (z, y, x) -> FITS (NAXIS1=x, NAXIS2=y, NAXIS3=z)
    so we must build numpy array shape (2, ny, nx).
    """
    if im1.shape != im2.shape:
        raise ValueError(f"Image shapes differ: im1={im1.shape}, im2={im2.shape}")
    return np.stack([im1, im2], axis=0)


def normalise_cube(cube: np.ndarray) -> np.ndarray:
    """
    IDL equivalent:
      im3 = im3 / max(im3)
    """
    mx = float(np.nanmax(cube))
    if not np.isfinite(mx) or mx == 0.0:
        return cube
    return cube / mx


def safe_jd_tag(jd: float) -> str:
    """
    Makes a filename-safe JD tag similar to what IDL effectively produced:
      'twosynths_'+strtrim(string(JD,format='(f15.7)'),2)+'.fits'
    We remove spaces and replace any awkward characters.
    """
    s = f"{jd:15.7f}".strip()
    # JD formatting should be digits + dot, so this is mostly just defensive:
    s = s.replace(" ", "")
    return s


def iter_jds_streaming(path: Path) -> float:
    """
    Stream JDs from file, one per line, like IDL READF in a loop.
    Ignores blank lines and comment lines starting with ';' or '#'.
    Also strips trailing comments after ';' or '#'.
    """
    with path.open("r", encoding="utf-8", errors="replace") as f:
        for raw in f:
            line = raw.strip()
            if not line:
                continue
            if line.startswith(";") or line.startswith("#"):
                continue

            # strip trailing comments
            line = line.split(";")[0].split("#")[0].strip()
            if not line:
                continue

            try:
                yield float(line)
            except ValueError:
                print(f"WARNING: cannot parse JD line: {raw.rstrip()!r}", file=sys.stderr)
                continue


def main() -> int:
    jd_path = Path(JD_FILE)
    if not jd_path.exists():
        print(f"ERROR: cannot find {JD_FILE} in {Path.cwd()}", file=sys.stderr)
        return 2

    # Quick count (optional, without loading all into memory)
    # We'll just stream and count as we go.
    n = 0

    try:
        for jd in iter_jds_streaming(jd_path):
            n += 1

            k = illuminated_fraction_moon(jd)
            if k is None:
                print(f"{jd:15.7f}  Illuminated fraction: (could not compute)")
            else:
                print(f"{jd:15.7f}  Illuminated fraction: {k:.6f}")

            im1, im2 = get_two_synthetic_images(jd)

            cube = stack_to_cube(im1, im2)
            cube = normalise_cube(cube)

            outname = f"twosynths_{safe_jd_tag(jd)}.fits"
            fits.writeto(outname, cube.astype(np.float32, copy=False), overwrite=True)
            print(f"Wrote {outname}")

    except KeyboardInterrupt:
        print("\nInterrupted by user. Exiting cleanly.", file=sys.stderr)
        return 130

    if n == 0:
        print(f"ERROR: no JD values found in {JD_FILE}", file=sys.stderr)
        return 2

    print(f"Done. Processed {n} JD values.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

