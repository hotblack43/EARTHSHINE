#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

CSV = Path("OUTPUT/COMBINED/jd_angdiam_2radius.csv")  # adjust if needed

# Plate scale from astrometry.net solution of NGC6633 (your comment)
PLATESCALE_ASTROM = 6.67203  # arcsec / pixel

def fit_platescale(x_pixdiam: np.ndarray, y_arcsec: np.ndarray) -> dict:
    """
    Fit plate scale from y (arcsec) vs x (pixels).

    Returns:
      - slope0: forced-through-origin slope (best for plate scale)
      - slope, intercept: ordinary least squares (with intercept)
    """
    # Force through origin: minimise ||y - m x||
    slope0 = float(np.dot(x_pixdiam, y_arcsec) / np.dot(x_pixdiam, x_pixdiam))

    # With intercept: y = m x + b
    m, b = np.polyfit(x_pixdiam, y_arcsec, 1)
    return {"slope0": float(m if False else slope0), "slope": float(m), "intercept": float(b)}

def main() -> int:
    if not CSV.exists():
        raise FileNotFoundError(f"Cannot find CSV: {CSV.resolve()}")

    df = pd.read_csv(CSV).copy()

    # Keep only usable rows
    need = ["jd", "two_times_radius_hdr", "ang_diam_arcsec_mlo"]
    df = df.dropna(subset=need).copy()

    df["jd"] = df["jd"].astype(float)
    df["pix_diam"] = df["two_times_radius_hdr"].astype(float)     # pixels
    df["ephem_arcsec"] = df["ang_diam_arcsec_mlo"].astype(float)  # arcsec

    # Sort by time for the JD plots
    df = df.sort_values("jd")

    x = df["pix_diam"].to_numpy()
    y = df["ephem_arcsec"].to_numpy()

    # Regression-derived plate scale
    fit = fit_platescale(x, y)
    platescale_origin = fit["slope0"]  # best estimate if we assume 0->0
    platescale_ols = fit["slope"]
    intercept_ols = fit["intercept"]

    print(f"Plate scale (astrometry.net / NGC6633): {PLATESCALE_ASTROM:.5f} arcsec/pix")
    print(f"Plate scale (fit, forced through origin): {platescale_origin:.5f} arcsec/pix")
    print(f"OLS fit (with intercept): y = {platescale_ols:.5f} * x + {intercept_ols:.3f} arcsec")

    # Predicted angular diameter from fixed plate scale(s)
    df["pred_astrom_arcsec"] = df["pix_diam"] * PLATESCALE_ASTROM
    df["pred_fit0_arcsec"] = df["pix_diam"] * platescale_origin

    # --------------------------
    # 1) OLD PLOT (correct)
    # --------------------------
    plt.figure()
    plt.scatter(df["pix_diam"], df["ephem_arcsec"])
    plt.xlabel("Measured Moon diameter = 2 × DISCRAD (pixels)")
    plt.ylabel("Ephemeris angular diameter (arcsec)")
    plt.title("Moon diameter: ephemeris vs measured pixel diameter")
    plt.show()

    # --------------------------
    # 2) COMPARISON PLOT (fixed)
    # ephemeris points + overlay predicted line(s)
    # --------------------------
    plt.figure()
    plt.scatter(df["pix_diam"], df["ephem_arcsec"], label="Ephemeris (arcsec)")

    # Lines: y = m x (no intercept)
    xline = np.array([np.min(x), np.max(x)], dtype=float)
    yline_astrom = xline * PLATESCALE_ASTROM
    yline_fit0 = xline * platescale_origin

    plt.plot(xline, yline_astrom, label=f"Predicted: x × {PLATESCALE_ASTROM:.5f} (astrometry)")
    plt.plot(xline, yline_fit0, label=f"Predicted: x × {platescale_origin:.5f} (fit, origin)")

    plt.xlabel("Measured Moon diameter = 2 × DISCRAD (pixels)")
    plt.ylabel("Angular diameter (arcsec)")
    plt.title("Ephemeris vs predicted using plate scale")
    plt.legend()
    plt.show()

    # --------------------------
    # 3) BOTH vs JD (fixed y-limits using BOTH series)
    # --------------------------
    y1 = df["ephem_arcsec"].to_numpy()
    y2 = df["pred_astrom_arcsec"].to_numpy()
    y3 = df["pred_fit0_arcsec"].to_numpy()

    ymin = float(np.min(np.concatenate([y1, y2, y3])))
    ymax = float(np.max(np.concatenate([y1, y2, y3])))
    pad = 0.03 * (ymax - ymin) if ymax > ymin else 1.0

    plt.figure()
    plt.scatter(df["jd"], df["ephem_arcsec"], label="Ephemeris (arcsec)")
    plt.scatter(df["jd"], df["pred_astrom_arcsec"], label=f"Measured×{PLATESCALE_ASTROM:.5f} (astrometry)")
    plt.scatter(df["jd"], df["pred_fit0_arcsec"], label=f"Measured×{platescale_origin:.5f} (fit, origin)")

    plt.xlabel("JD")
    plt.ylabel("Angular diameter (arcsec)")
    plt.title("Moon angular diameter vs JD (ephemeris and header-derived)")
    plt.ylim(ymin - pad, ymax + pad)
    plt.legend()
    plt.show()

    return 0

if __name__ == "__main__":
    raise SystemExit(main())

