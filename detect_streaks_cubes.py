#!/usr/bin/env python3
#
# uv run detect_streaks_cubes.py --layer 1
#
from __future__ import annotations

import argparse
import csv
import re
from pathlib import Path
from typing import Tuple, Optional, List, Dict

import numpy as np
from astropy.io import fits


JD_REGEX = re.compile(r"(24\d{5}\.\d{3,10})")


def extract_jd_from_filename(name: str) -> Optional[float]:
    m = JD_REGEX.search(name)
    if not m:
        return None
    try:
        return float(m.group(1))
    except Exception:
        return None


def get_layer_image(cube: np.ndarray, layer_index_1based: int) -> np.ndarray:
    """
    Return the requested layer (1-based) as a 2D image.
    Supports cubes shaped (nl, ny, nx) or (ny, nx, nl).
    """
    if cube.ndim == 2:
        raise ValueError("FITS contains 2D image, not a cube")

    if cube.ndim != 3:
        raise ValueError(f"Expected 3D cube, got ndim={cube.ndim}, shape={cube.shape}")

    li = layer_index_1based - 1
    if li < 0:
        raise ValueError("layer_index_1based must be >= 1")

    # Heuristic: layer axis is the one with smallest size (usually 8..20)
    shape = cube.shape
    layer_axis = int(np.argmin(shape))

    if layer_axis == 0:
        # (nl, ny, nx)
        if li >= shape[0]:
            raise IndexError(f"Requested layer {layer_index_1based} but cube has {shape[0]} layers")
        img = cube[li, :, :]
    elif layer_axis == 2:
        # (ny, nx, nl)
        if li >= shape[2]:
            raise IndexError(f"Requested layer {layer_index_1based} but cube has {shape[2]} layers")
        img = cube[:, :, li]
    else:
        # Rare: (ny, nl, nx) etc — handle explicitly
        if layer_axis == 1:
            if li >= shape[1]:
                raise IndexError(f"Requested layer {layer_index_1based} but cube has {shape[1]} layers on axis 1")
            img = cube[:, li, :]
        else:
            raise ValueError(f"Unexpected layer axis={layer_axis} for shape={shape}")

    img = np.asarray(img, dtype=np.float32)
    if img.ndim != 2:
        raise ValueError(f"Layer extraction failed; got shape {img.shape}")
    return img


def robust_mad(x: np.ndarray) -> float:
    x = x[np.isfinite(x)]
    if x.size == 0:
        return float("nan")
    med = float(np.median(x))
    mad = float(np.median(np.abs(x - med)))
    return mad


def score_edges(img: np.ndarray, k: int) -> Dict[str, float]:
    """
    Compute edge-band summaries and a couple of robust scores.

    Returns dict with:
      T, B (medians of top/bottom band profiles),
      delta (T-B),
      asym ( (T-B)/(T+B+eps) ),
      mid (median of mid band),
      top_mid_ratio, bot_mid_ratio,
      delta_sigma (delta normalized by robust scatter in image)
    """
    ny, nx = img.shape
    if k < 1 or k >= ny // 2:
        raise ValueError(f"k must be between 1 and ny/2-1; got k={k}, ny={ny}")

    top_band = img[0:k, :]
    bot_band = img[ny - k:ny, :]

    # Middle reference band (same thickness), centred
    mid0 = ny // 2 - k // 2
    mid1 = mid0 + k
    mid_band = img[mid0:mid1, :]

    # Use median across rows => 1D profile, robust to hot pixels
    top_prof = np.nanmedian(top_band, axis=0)
    bot_prof = np.nanmedian(bot_band, axis=0)
    mid_prof = np.nanmedian(mid_band, axis=0)

    T = float(np.nanmedian(top_prof))
    B = float(np.nanmedian(bot_prof))
    M = float(np.nanmedian(mid_prof))

    delta = T - B
    eps = 1e-12
    asym = delta / (T + B + eps)

    # Ratios vs mid (protect against M near zero)
    top_mid_ratio = T / (M + eps)
    bot_mid_ratio = B / (M + eps)

    # Robust scatter of the whole image
    mad = robust_mad(img)
    sigma_robust = 1.4826 * mad if np.isfinite(mad) else float("nan")
    delta_sigma = delta / (sigma_robust + eps) if np.isfinite(sigma_robust) else float("nan")

    return {
        "T": T,
        "B": B,
        "M": M,
        "delta": float(delta),
        "asym": float(asym),
        "top_mid_ratio": float(top_mid_ratio),
        "bot_mid_ratio": float(bot_mid_ratio),
        "sigma_robust": float(sigma_robust),
        "delta_sigma": float(delta_sigma),
    }


def classify(score: Dict[str, float], asym_bad: float, sigma_bad: float) -> str:
    """
    Simple rule:
      - "BAD" if |asym| >= asym_bad OR |delta_sigma| >= sigma_bad
      - otherwise "OK"
    """
    a = abs(score["asym"])
    ds = abs(score["delta_sigma"])
    if (np.isfinite(a) and a >= asym_bad) or (np.isfinite(ds) and ds >= sigma_bad):
        return "BAD"
    return "OK"


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Detect edge streak contamination using top/bottom edge bands from a chosen cube layer."
    )
    ap.add_argument("--indir", type=str, default="OUTPUT/COMBINED", help="Directory containing combined FITS cubes.")
    ap.add_argument("--glob", type=str, default="*.fit*", help="Glob for FITS files (fits/fits.gz/fit).")
    ap.add_argument("--layer", type=int, default=3, help="Which cube layer to inspect (1-based). Default: 3rd image.")
    ap.add_argument("--k", type=int, default=10, help="Number of top/bottom rows to use as edge bands. Default: 10.")
    ap.add_argument("--asym-bad", type=float, default=0.05,
                    help="Flag BAD if |(T-B)/(T+B)| >= this. Default: 0.05")
    ap.add_argument("--sigma-bad", type=float, default=6.0,
                    help="Flag BAD if |(T-B)/sigma_robust| >= this. Default: 6.0")
    ap.add_argument("--outcsv", type=str, default="OUTPUT/COMBINED/edge_streak_scores.csv",
                    help="Write per-file scores here.")
    ap.add_argument("--oklist", type=str, default="OUTPUT/COMBINED/ok_images.txt",
                    help="Write list of OK images here.")
    ap.add_argument("--badlist", type=str, default="OUTPUT/COMBINED/bad_images.txt",
                    help="Write list of BAD images here.")
    args = ap.parse_args()

    indir = Path(args.indir)
    if not indir.exists():
        print(f"ERROR: directory not found: {indir.resolve()}")
        return 2

    files = sorted(indir.glob(args.glob))
    if not files:
        print(f"ERROR: no files matched {args.glob} in {indir.resolve()}")
        return 2

    outcsv = Path(args.outcsv)
    oklist = Path(args.oklist)
    badlist = Path(args.badlist)
    outcsv.parent.mkdir(parents=True, exist_ok=True)
    oklist.parent.mkdir(parents=True, exist_ok=True)
    badlist.parent.mkdir(parents=True, exist_ok=True)

    rows: List[Dict[str, object]] = []
    ok_files: List[str] = []
    bad_files: List[str] = []

    print(f"Scanning {len(files)} files in {indir.resolve()}")
    print(f"Using layer={args.layer} (1-based), edge band k={args.k} rows")
    print(f"BAD if |asym|>={args.asym_bad} OR |delta_sigma|>={args.sigma_bad}\n")

    n_bad = 0
    n_ok = 0
    n_err = 0

    for i, p in enumerate(files, start=1):
        print(f"[{i:4d}/{len(files)}] {p.name}")
        try:
            with fits.open(p) as hdul:
                data = hdul[0].data
                hdr = hdul[0].header

            if data is None:
                raise ValueError("No data in primary HDU")

            cube = np.asarray(data, dtype=np.float32)
            img = get_layer_image(cube, args.layer)

            sc = score_edges(img, args.k)
            status = classify(sc, args.asym_bad, args.sigma_bad)

            jd_hdr = None
            for key in ["JD", "JD-OBS", "SCJD", "MJD", "MJD-OBS"]:
                if key in hdr:
                    try:
                        jd_hdr = float(hdr[key])
                        if key.startswith("MJD"):
                            jd_hdr = jd_hdr + 2400000.5
                        break
                    except Exception:
                        pass

            jd_name = extract_jd_from_filename(p.name)

            rec = {
                "filename": p.name,
                "jd_from_header": jd_hdr if jd_hdr is not None else "",
                "jd_from_name": jd_name if jd_name is not None else "",
                "layer": args.layer,
                "k": args.k,
                "T": sc["T"],
                "B": sc["B"],
                "M": sc["M"],
                "delta": sc["delta"],
                "asym": sc["asym"],
                "sigma_robust": sc["sigma_robust"],
                "delta_sigma": sc["delta_sigma"],
                "top_mid_ratio": sc["top_mid_ratio"],
                "bot_mid_ratio": sc["bot_mid_ratio"],
                "status": status,
            }
            rows.append(rec)

            if status == "BAD":
                bad_files.append(p.name)
                n_bad += 1
                print(f"   -> BAD  asym={sc['asym']:+.4f}  delta_sigma={sc['delta_sigma']:+.2f}")
            else:
                ok_files.append(p.name)
                n_ok += 1
                print(f"   -> OK   asym={sc['asym']:+.4f}  delta_sigma={sc['delta_sigma']:+.2f}")

        except Exception as e:
            n_err += 1
            print(f"   -> ERROR: {e}")
            rows.append({"filename": p.name, "status": "ERROR", "error": str(e)})

    # Write CSV
    fieldnames = [
        "filename",
        "jd_from_header",
        "jd_from_name",
        "layer",
        "k",
        "T", "B", "M",
        "delta",
        "asym",
        "sigma_robust",
        "delta_sigma",
        "top_mid_ratio",
        "bot_mid_ratio",
        "status",
        "error",
    ]
    with outcsv.open("w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=fieldnames, extrasaction="ignore")
        w.writeheader()
        for r in rows:
            w.writerow(r)

    oklist.write_text("\n".join(ok_files) + ("\n" if ok_files else ""), encoding="utf-8")
    badlist.write_text("\n".join(bad_files) + ("\n" if bad_files else ""), encoding="utf-8")

    print("\nDone.")
    print(f"OK: {n_ok}   BAD: {n_bad}   ERROR: {n_err}")
    print(f"Wrote: {outcsv.resolve()}")
    print(f"Wrote: {oklist.resolve()}")
    print(f"Wrote: {badlist.resolve()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

