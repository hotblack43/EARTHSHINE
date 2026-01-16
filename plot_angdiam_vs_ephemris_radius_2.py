#!/usr/bin/env python3
from __future__ import annotations

from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

CSV = Path("OUTPUT/COMBINED/jd_angdiam_2radius.csv")  # adjust if needed

def main() -> int:
    if not CSV.exists():
        raise FileNotFoundError(f"Cannot find CSV: {CSV.resolve()}")

    df = pd.read_csv(CSV).copy()

    # Keep only rows that have what we need
    need = ["jd", "two_times_radius_hdr", "ang_diam_arcsec_mlo"]
    df = df.dropna(subset=need)

    df["jd"] = df["jd"].astype(float)
    df["two_times_radius_hdr"] = df["two_times_radius_hdr"].astype(float)   # pixels
    df["ang_diam_arcsec_mlo"] = df["ang_diam_arcsec_mlo"].astype(float)     # arcsec

    # ------------------------------------------------------------------
    # 1) OLD plot: ephemeris angular diameter (arcsec) vs header diameter (pixels)
    # ------------------------------------------------------------------
    plt.figure()
    plt.scatter(df["two_times_radius_hdr"], df["ang_diam_arcsec_mlo"])
    plt.xlabel("2 × header radius (pixels)")
    plt.ylabel("Ephemeris angular diameter (arcsec)")
    plt.title("Moon diameter: ephemeris vs header radius")
    plt.show()

    # ------------------------------------------------------------------
    # Plate scale estimate from the data (robust median)
    # plate scale = arcsec / pixel = (ephem_diam_arcsec) / (pixel_diam)
    # ------------------------------------------------------------------
    df["platescale_arcsec_per_pix"] = df["ang_diam_arcsec_mlo"] / df["two_times_radius_hdr"]
    ps_med = float(np.median(df["platescale_arcsec_per_pix"].to_numpy()))
    print(f"Median plate scale from data: {ps_med:.5f} arcsec/pixel")

    # ------------------------------------------------------------------
    # 2) Plot that assumes this plate scale: predicted angular diameter (arcsec)
    #    predicted = pixel_diam * plate_scale
    # ------------------------------------------------------------------
    df["ang_diam_pred_arcsec"] = df["two_times_radius_hdr"] * ps_med

    plt.figure()
    plt.scatter(df["two_times_radius_hdr"], df["ang_diam_pred_arcsec"])
    plt.xlabel("2 × header radius (pixels)")
    plt.ylabel(f"Predicted angular diameter (arcsec) using {ps_med:.4f} arcsec/pix")
    plt.title("Moon diameter: predicted (from header radius × plate scale)")
    plt.show()

    # ------------------------------------------------------------------
    # 3) Plot BOTH vs JD
    # ------------------------------------------------------------------
    plt.figure()
    plt.scatter(df["jd"], df["ang_diam_arcsec_mlo"], label="Ephemeris (arcsec)")
    plt.scatter(df["jd"], df["ang_diam_pred_arcsec"], label=f"Header×{ps_med:.4f} (arcsec)")
    plt.xlabel("JD")
    plt.ylabel("Angular diameter (arcsec)")
    plt.title("Moon angular diameter vs JD (ephemeris and header-derived)")
    plt.legend()
    plt.show()

    return 0

if __name__ == "__main__":
    raise SystemExit(main())

