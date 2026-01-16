#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

CSV = Path("OUTPUT/COMBINED/jd_angdiam_2radius.csv")  # adjust if needed
PLATESCALE_ASTROM = 6.67203  # arcsec/pix (from your NGC6633 solve)

def fit_slope_through_origin(x: np.ndarray, y: np.ndarray) -> float:
    # minimise ||y - m x||  =>  m = (x·y)/(x·x)
    return float(np.dot(x, y) / np.dot(x, x))

def main() -> int:
    if not CSV.exists():
        raise FileNotFoundError(f"Cannot find CSV: {CSV.resolve()}")

    df = pd.read_csv(CSV).dropna(subset=["jd", "two_times_radius_hdr", "ang_diam_arcsec_mlo"]).copy()
    df["jd"] = df["jd"].astype(float)
    df["pix_diam"] = df["two_times_radius_hdr"].astype(float)
    df["ephem_arcsec"] = df["ang_diam_arcsec_mlo"].astype(float)
    df = df.sort_values("jd")

    x = df["pix_diam"].to_numpy()
    y = df["ephem_arcsec"].to_numpy()

    platescale_fit0 = fit_slope_through_origin(x, y)
    print(f"Plate scale (astrometry.net / NGC6633): {PLATESCALE_ASTROM:.5f} arcsec/pix")
    print(f"Plate scale (fit, forced through origin): {platescale_fit0:.5f} arcsec/pix")

    df["pred_astrom_arcsec"] = df["pix_diam"] * PLATESCALE_ASTROM
    df["pred_fit0_arcsec"] = df["pix_diam"] * platescale_fit0

    # 1) old plot
    plt.figure()
    plt.scatter(df["pix_diam"], df["ephem_arcsec"])
    plt.xlabel("Measured Moon diameter = 2 × DISCRAD (pixels)")
    plt.ylabel("Ephemeris angular diameter (arcsec)")
    plt.title("Moon diameter: ephemeris vs measured pixel diameter")
    plt.show()

    # 2) comparison plot
    plt.figure()
    plt.scatter(df["pix_diam"], df["ephem_arcsec"], label="Ephemeris (arcsec)")
    xline = np.array([np.min(x), np.max(x)], dtype=float)
    plt.plot(xline, xline * PLATESCALE_ASTROM, label=f"Predicted: x × {PLATESCALE_ASTROM:.5f} (astrometry)")
    plt.plot(xline, xline * platescale_fit0, label=f"Predicted: x × {platescale_fit0:.5f} (fit, origin)")
    plt.xlabel("Measured Moon diameter = 2 × DISCRAD (pixels)")
    plt.ylabel("Angular diameter (arcsec)")
    plt.title("Ephemeris vs predicted using plate scale")
    plt.legend()
    plt.show()

    # 3) both vs JD (SMALLER symbols + y-limits from ALL series)
    y_ephem = df["ephem_arcsec"].to_numpy()
    y_astrom = df["pred_astrom_arcsec"].to_numpy()
    y_fit0 = df["pred_fit0_arcsec"].to_numpy()

    # ✅ y-range from min/max of ALL series combined
    y_all = np.concatenate([y_ephem, y_astrom, y_fit0])
    ymin = float(np.min(y_all))
    ymax = float(np.max(y_all))
    pad = 0.03 * (ymax - ymin) if ymax > ymin else 1.0

    plt.figure()
    plt.scatter(df["jd"], df["ephem_arcsec"], s=8, label="Ephemeris (arcsec)")
    plt.scatter(df["jd"], df["pred_astrom_arcsec"], s=8, label=f"Measured×{PLATESCALE_ASTROM:.5f} (astrometry)")
    plt.scatter(df["jd"], df["pred_fit0_arcsec"], s=8, label=f"Measured×{platescale_fit0:.5f} (fit, origin)")
    plt.xlabel("JD")
    plt.ylabel("Angular diameter (arcsec)")
    plt.title("Moon angular diameter vs JD (ephemeris and header-derived)")
    plt.ylim(ymin - pad, ymax + pad)
    plt.legend()
    plt.show()

    return 0

if __name__ == "__main__":
    raise SystemExit(main())

