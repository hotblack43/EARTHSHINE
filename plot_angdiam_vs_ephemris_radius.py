#!/usr/bin/env python3
#
# uv run plot_angdiam_vs_ephemris_radius.py
#

from __future__ import annotations

from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

CSV = Path("OUTPUT/COMBINED/jd_angdiam_2radius.csv")  # adjust if needed

def main() -> int:
    if not CSV.exists():
        raise FileNotFoundError(f"Cannot find CSV: {CSV.resolve()}")

    df = pd.read_csv(CSV)

    # Keep only rows that have both values
    df = df.dropna(subset=["two_times_radius_hdr", "ang_diam_arcsec_mlo"])

    x = df["two_times_radius_hdr"].astype(float)     # 2 * radius from header (pixels)
    y = df["ang_diam_arcsec_mlo"].astype(float)      # ephemeris angular diameter (arcsec)

    plt.figure()
    plt.scatter(x, y)
    plt.xlabel("2 × header radius (pixels)")
    plt.ylabel("Ephemeris angular diameter (arcsec)")
    plt.title("Moon diameter: ephemeris vs header radius")
    plt.show()

    # Optional: quick linear fit (arcsec per pixel)
    m, b = (y.cov(x) / x.var()), (y.mean() - (y.cov(x) / x.var()) * x.mean())
    print(f"Linear fit: ang_diam_arcsec ≈ {m:.6f} * (2*radius_px) + {b:.3f}")

    return 0

if __name__ == "__main__":
    raise SystemExit(main())

