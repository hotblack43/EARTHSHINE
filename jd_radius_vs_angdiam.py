#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
from typing import Optional, Tuple, List

import numpy as np
from astropy.io import fits
from astropy.time import Time
from astropy import units as u
from astropy.coordinates import EarthLocation, get_body

# ---------------- SETTINGS ----------------
COMBINED_DIR = Path("OUTPUT/COMBINED")
OUT_CSV = COMBINED_DIR / "jd_angdiam_2radius.csv"

# Mauna Loa Observatory (approx.)
MLO = EarthLocation(lat=19.5362*u.deg, lon=(-155.5763)*u.deg, height=3397*u.m)

# Mean lunar radius (km)
R_MOON = 1737.4 * u.km

# JD-like keys to try (supports MJD -> JD conversion)
JD_KEYS = ["SCJD", "JD-OBS", "MJD", "MJD-OBS"]

# Radius keys to try (whatever your pipeline used)
RADIUS_KEYS = [
    "DISCRAD", "RADIUSPX", "RADIUS_PIX", "RADPIX", "MOONRAD", "MOONR",
    "DISKRAD", "DISK_RAD", "LUNAR_R", "R_MOON", "RPIX", "R_PIX"
]
# ------------------------------------------


def get_jd_from_header(hdr: fits.Header) -> Optional[Tuple[float, str]]:
    for key in JD_KEYS:
        if key in hdr:
            try:
                val = float(hdr[key])
            except Exception:
                continue
            if key.startswith("MJD"):
                return val + 2400000.5, key
            return val, key
    return None


def get_radius_from_header(hdr: fits.Header) -> Optional[Tuple[float, str]]:
    for key in RADIUS_KEYS:
        if key in hdr:
            try:
                val = float(hdr[key])
            except Exception:
                continue
            return val, key
    return None


def moon_angular_diameter_arcmin_at_mlo(jd_utc: float) -> float:
    t = Time(jd_utc, format="jd", scale="utc")
    moon = get_body("moon", t, MLO)          # topocentric position
    d = moon.distance.to(u.km)               # topocentric distance
    theta = 2.0 * np.arctan((R_MOON / d).decompose().value) * u.rad
    return theta.to(u.arcmin).value


def main() -> int:
    if not COMBINED_DIR.exists():
        print(f"ERROR: directory not found: {COMBINED_DIR.resolve()}")
        return 2

    files = sorted(COMBINED_DIR.glob("*.fit*"))
    if not files:
        print(f"ERROR: no FITS files found in: {COMBINED_DIR.resolve()}")
        return 2

    rows: List[str] = []
    header = [
        "filename",
        "jd",
        "jd_key",
        "radius_hdr",
        "radius_key",
        "two_times_radius_hdr",
        "ang_diam_arcmin_mlo",
        "ang_diam_arcsec_mlo",
    ]
    rows.append(",".join(header))

    n_ok = 0
    n_warn = 0

    for p in files:
        try:
            with fits.open(p) as hdul:
                hdr = hdul[0].header

            jd_got = get_jd_from_header(hdr)
            rad_got = get_radius_from_header(hdr)

            if jd_got is None or rad_got is None:
                n_warn += 1
                jd_val = "" if jd_got is None else f"{jd_got[0]:.10f}"
                jd_key = "" if jd_got is None else jd_got[1]
                rad_val = "" if rad_got is None else f"{rad_got[0]:.6f}"
                rad_key = "" if rad_got is None else rad_got[1]
                print(f"WARNING: missing JD or radius in {p.name}  (JD={jd_key or 'none'}, R={rad_key or 'none'})")
                rows.append(",".join([p.name, jd_val, jd_key, rad_val, rad_key, "", "", ""]))
                continue

            jd, jd_key = jd_got
            radius, rad_key = rad_got

            ang_arcmin = moon_angular_diameter_arcmin_at_mlo(jd)
            ang_arcsec = ang_arcmin * 60.0

            two_r = 2.0 * radius

            rows.append(",".join([
                p.name,
                f"{jd:.10f}",
                jd_key,
                f"{radius:.6f}",
                rad_key,
                f"{two_r:.6f}",
                f"{ang_arcmin:.8f}",
                f"{ang_arcsec:.3f}",
            ]))
            n_ok += 1

        except Exception as e:
            n_warn += 1
            print(f"WARNING: failed on {p.name}: {e}")
            rows.append(",".join([p.name, "", "", "", "", "", "", ""]))

    COMBINED_DIR.mkdir(parents=True, exist_ok=True)
    OUT_CSV.write_text("\n".join(rows) + "\n", encoding="utf-8")

    print(f"\nDone. OK={n_ok}  warnings={n_warn}")
    print(f"Wrote: {OUT_CSV.resolve()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

