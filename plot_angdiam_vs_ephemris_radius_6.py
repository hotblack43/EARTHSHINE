#!/usr/bin/env python3
from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

CSV_DEFAULT = Path("OUTPUT/COMBINED/jd_angdiam_2radius.csv")
PLATESCALE_ASTROM = 6.67203  # arcsec/pix (from your NGC6633 solution comment)


def fit_slope_through_origin(x: np.ndarray, y: np.ndarray) -> float:
    # minimise ||y - m x||  =>  m = (x·y)/(x·x)
    return float(np.dot(x, y) / np.dot(x, x))


def set_ylim_from_all_series(series_list: list[np.ndarray]) -> tuple[float, float]:
    y_all = np.concatenate(series_list)
    ymin = float(np.min(y_all))
    ymax = float(np.max(y_all))
    pad = 0.03 * (ymax - ymin) if ymax > ymin else 1.0
    return ymin - pad, ymax + pad


def main() -> int:
    ap = argparse.ArgumentParser(description="Moon diameter plots: ephemeris vs measured radius and JD.")
    ap.add_argument("--csv", type=str, default=str(CSV_DEFAULT), help="Input CSV (jd_angdiam_2radius.csv).")
    ap.add_argument(
        "--pdf",
        type=str,
        default="",
        help="If set, ALSO write a multi-page PDF with the 3 plots (still shows on screen).",
    )
    args = ap.parse_args()

    csv_path = Path(args.csv)
    if not csv_path.exists():
        raise FileNotFoundError(f"Cannot find CSV: {csv_path.resolve()}")

    do_pdf = bool(args.pdf)
    pdf_path = Path(args.pdf) if do_pdf else None
    pdf = PdfPages(pdf_path) if do_pdf else None

    df = pd.read_csv(csv_path).dropna(subset=["jd", "two_times_radius_hdr", "ang_diam_arcsec_mlo"]).copy()
    df["jd"] = df["jd"].astype(float)
    df["pix_diam"] = df["two_times_radius_hdr"].astype(float)       # pixels = 2*DISCRAD
    df["ephem_arcsec"] = df["ang_diam_arcsec_mlo"].astype(float)    # arcsec
    df = df.sort_values("jd")

    x = df["pix_diam"].to_numpy()
    y = df["ephem_arcsec"].to_numpy()

    platescale_fit0 = fit_slope_through_origin(x, y)

    print(f"Plate scale (given, astrometry.net / NGC6633): {PLATESCALE_ASTROM:.5f} arcsec/pix")
    print(f"Plate scale (fitted from Moon diameters, forced through origin): {platescale_fit0:.5f} arcsec/pix")

    # Predictions
    df["pred_astrom_arcsec"] = df["pix_diam"] * PLATESCALE_ASTROM
    df["pred_fit0_arcsec"] = df["pix_diam"] * platescale_fit0

    # --------------------------
    # 1) Old plot: ephemeris vs measured pixel diameter
    # --------------------------
    fig1 = plt.figure()
    plt.scatter(df["pix_diam"], df["ephem_arcsec"], s=18)  # default colour dot
    plt.xlabel("Measured Moon diameter = 2 × DISCRAD (pixels)")
    plt.ylabel("Ephemeris angular diameter (arcsec)")
    plt.title("Moon diameter: ephemeris vs measured pixel diameter")
    if do_pdf:
        pdf.savefig(fig1, bbox_inches="tight")
    plt.show()
    plt.close(fig1)

    # --------------------------
    # 2) Comparison: ephemeris points + predicted lines (given vs fitted)
    # --------------------------
    fig2 = plt.figure()
    plt.scatter(df["pix_diam"], df["ephem_arcsec"], s=18, label="Ephemeris (arcsec)")

    xline = np.array([np.min(x), np.max(x)], dtype=float)
    plt.plot(xline, xline * PLATESCALE_ASTROM, label=f"Predicted: x × {PLATESCALE_ASTROM:.5f} (given)")
    plt.plot(xline, xline * platescale_fit0, label=f"Predicted: x × {platescale_fit0:.5f} (fitted)")

    plt.xlabel("Measured Moon diameter = 2 × DISCRAD (pixels)")
    plt.ylabel("Angular diameter (arcsec)")
    plt.title("Ephemeris vs predicted using plate scale")
    plt.legend()
    if do_pdf:
        pdf.savefig(fig2, bbox_inches="tight")
    plt.show()
    plt.close(fig2)

    # --------------------------
    # 3) Both vs JD:
    #   - Ephemeris: coloured dots
    #   - Given plate scale: different coloured dots
    #   - Fitted plate scale: small black crosses
    #   - y-limits from min/max of ALL series shown
    # --------------------------
    y_ephem = df["ephem_arcsec"].to_numpy()
    y_given = df["pred_astrom_arcsec"].to_numpy()
    y_fit = df["pred_fit0_arcsec"].to_numpy()

    ylim_lo, ylim_hi = set_ylim_from_all_series([y_ephem, y_given, y_fit])

    fig3 = plt.figure()

    # Ephemeris (measured truth): dots (default blue)
    plt.scatter(df["jd"], df["ephem_arcsec"], s=10, label="Ephemeris (arcsec)")

    # Fitted plate scale prediction: small black crosses
    plt.scatter(
        df["jd"], df["pred_fit0_arcsec"],
        s=14, marker="x", color="black",
        label=f"Measured×{platescale_fit0:.5f} (fitted plate scale)"
    )
    # Given plate scale prediction: dots in a different colour (orange)
    plt.scatter(
        df["jd"], df["pred_astrom_arcsec"],
        s=10, color="orange",
        label=f"Measured×{PLATESCALE_ASTROM:.5f} (given plate scale)"
    )


    plt.xlabel("JD")
    plt.ylabel("Angular diameter (arcsec)")
    plt.title("Moon angular diameter vs JD (ephemeris + two predictions)")
    plt.ylim(ylim_lo, ylim_hi)
    plt.legend()
    if do_pdf:
        pdf.savefig(fig3, bbox_inches="tight")
    plt.show()
    plt.close(fig3)

    if do_pdf:
        pdf.close()
        print(f"Wrote multi-page PDF: {pdf_path.resolve()}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

