#!/usr/bin/env python3
"""
demo_match_dark_and_make_composite.py

Demo utility:
  For each science (AVG) frame in allJDsFromImages.txt:
    - parse JD from filename
    - find DARK just before and just after (by JD) from allDARKframes.txt
    - report matches + time offsets
    - read the two DARK FITS files (supports .fits and .fits.gz)
    - create composite DARK = 0.5*(dark_before + dark_after)
    - write composite DARK to out-dir
    - write CSV summary

Assumptions:
  - Basenames contain JD like: 2456017.7238820...fits(.gz)
  - DARK frames are 512x512 (or cubes that can be reduced to 2D by averaging)
"""

from __future__ import annotations

import argparse
import bisect
import csv
import os
import re
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import List, Optional, Tuple

import numpy as np
from astropy.io import fits

JD_RE = re.compile(r"(245\d{4,}\.\d+)")


@dataclass(frozen=True)
class JDFile:
    jd: float
    path: str


def read_list(path: str) -> List[str]:
    out: List[str] = []
    with open(path, "r", encoding="utf-8", errors="replace") as f:
        for line in f:
            s = line.strip()
            if not s or s.startswith("#"):
                continue
            out.append(os.path.abspath(os.path.expanduser(s)))
    return out


def parse_jd_from_path(p: str) -> Optional[float]:
    base = os.path.basename(p)
    m = JD_RE.search(base)
    if m:
        return float(m.group(1))
    m = JD_RE.search(p)
    if m:
        return float(m.group(1))
    return None


def build_sorted(paths: List[str], label: str) -> Tuple[List[float], List[JDFile], List[str]]:
    items: List[JDFile] = []
    bad: List[str] = []
    for p in paths:
        jd = parse_jd_from_path(p)
        if jd is None:
            bad.append(p)
            continue
        items.append(JDFile(jd=jd, path=p))
    items.sort(key=lambda x: x.jd)
    jds = [x.jd for x in items]
    if not items:
        raise RuntimeError(f"No parsable JDs found in {label} list.")
    return jds, items, bad


def find_bracketing(dark_jds: List[float], dark_items: List[JDFile], target_jd: float) -> Tuple[Optional[JDFile], Optional[JDFile]]:
    """
    Strictly before and strictly after. If no bracketing exists, returns None for that side.
    """
    i = bisect.bisect_left(dark_jds, target_jd)
    before = dark_items[i - 1] if i - 1 >= 0 else None

    j = bisect.bisect_right(dark_jds, target_jd)
    after = dark_items[j] if j < len(dark_items) else None

    return before, after


def days_to_seconds(dt_days: float) -> float:
    return dt_days * 86400.0


def fmt_dt(dt_days: Optional[float]) -> str:
    if dt_days is None:
        return "NA"
    s = days_to_seconds(dt_days)
    return f"{dt_days:+.8f} d  ({s:+.1f} s)"


def read_fits_as_2d(path: str, expect_shape: Optional[Tuple[int, int]] = (512, 512)) -> Tuple[np.ndarray, fits.Header]:
    """
    Read FITS (.fits or .fits.gz) and return a 2D float32 image.
    If FITS contains a cube, we reduce it to 2D by averaging along the frame axis.
    """
    with fits.open(path, memmap=False) as hdul:
        # pick first HDU with data
        hdu = None
        for h in hdul:
            if h.data is not None:
                hdu = h
                break
        if hdu is None:
            raise RuntimeError("No image data in FITS")

        data = np.asarray(hdu.data)
        hdr = hdu.header.copy()

        if data.ndim == 2:
            img = data.astype(np.float32, copy=False)
        elif data.ndim == 3:
            # Try to guess axis order; reduce to 2D by averaging frames.
            # Common cases: (n,ny,nx) or (ny,nx,n)
            if data.shape[0] in (1, 2, 3, 10, 100) and data.shape[-2:] == expect_shape:
                # (n,ny,nx)
                img = np.mean(data.astype(np.float32, copy=False), axis=0)
            elif data.shape[0:2] == expect_shape:
                # (ny,nx,n)
                img = np.mean(data.astype(np.float32, copy=False), axis=2)
            else:
                # fallback: average over the smallest axis
                ax = int(np.argmin(data.shape))
                img = np.mean(data.astype(np.float32, copy=False), axis=ax)
        else:
            raise RuntimeError(f"Unsupported ndim={data.ndim}")

        if expect_shape is not None and img.shape != expect_shape:
            raise RuntimeError(f"Unexpected image shape {img.shape}, expected {expect_shape}")

        return img, hdr


def make_out_name(science_path: str, out_dir: str, suffix: str = "_DARKCOMP") -> str:
    base = os.path.basename(science_path)
    if base.lower().endswith(".gz"):
        base = base[:-3]
    for ext in (".fits", ".fit", ".fts"):
        if base.lower().endswith(ext):
            base = base[: -len(ext)]
            break
    out = os.path.join(out_dir, f"{base}{suffix}.fits")
    return out


def write_composite_dark(out_path: str, comp: np.ndarray, sci_path: str, sci_jd: float,
                         dark_before: JDFile, dark_after: JDFile,
                         dt_before_days: float, dt_after_days: float) -> None:
    hdr = fits.Header()
    hdr["SCPATH"] = (os.path.basename(sci_path)[:68], "Science filename (truncated)")
    hdr["SCJD"] = (float(sci_jd), "Science JD from filename")
    hdr["DBPATH"] = (os.path.basename(dark_before.path)[:68], "Dark before filename (truncated)")
    hdr["DAFTER"] = (os.path.basename(dark_after.path)[:68], "Dark after filename (truncated)")
    hdr["DBJD"] = (float(dark_before.jd), "Dark before JD")
    hdr["DAJD"] = (float(dark_after.jd), "Dark after JD")
    hdr["DTB_D"] = (float(dt_before_days), "DBJD - SCJD [days] (negative)")
    hdr["DTA_D"] = (float(dt_after_days), "DAJD - SCJD [days] (positive)")
    hdr["DTB_S"] = (float(days_to_seconds(dt_before_days)), "DBJD - SCJD [seconds]")
    hdr["DTA_S"] = (float(days_to_seconds(dt_after_days)), "DAJD - SCJD [seconds]")

    now = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    hdr.add_history(f"Composite dark created {now}")
    hdr.add_history("Composite dark = 0.5*(dark_before + dark_after)")
    hdr.add_history("Source JDs parsed from filenames")

    os.makedirs(os.path.dirname(out_path) or ".", exist_ok=True)
    fits.PrimaryHDU(data=comp.astype(np.float32, copy=False), header=hdr).writeto(out_path, overwrite=True)


def main() -> int:
    ap = argparse.ArgumentParser(description="Demo: for each science frame, bracket by DARKs and write composite dark.")
    ap.add_argument("--science-list", default="allJDsFromImages.txt")
    ap.add_argument("--dark-list", default="allDARKframes.txt")
    ap.add_argument("--out-dir", default="DARKCOMPOSITES_DEMO")
    ap.add_argument("--csv-out", default="dark_brackets_with_composites.csv")
    ap.add_argument("--max-print", type=int, default=30)
    ap.add_argument("--expect-ny", type=int, default=512)
    ap.add_argument("--expect-nx", type=int, default=512)
    args = ap.parse_args()

    sci_paths = read_list(args.science_list)
    dark_paths = read_list(args.dark_list)

    if not sci_paths:
        print(f"ERROR: science list is empty: {args.science_list}", file=sys.stderr)
        return 2
    if not dark_paths:
        print(f"ERROR: dark list is empty: {args.dark_list}", file=sys.stderr)
        return 2

    dark_jds, dark_items, dark_bad = build_sorted(dark_paths, "DARK")
    sci_jds, sci_items, sci_bad = build_sorted(sci_paths, "SCIENCE")

    print(f"Loaded SCIENCE: {len(sci_items)} (bad JD parse: {len(sci_bad)})")
    print(f"Loaded DARK:    {len(dark_items)} (bad JD parse: {len(dark_bad)})")

    if sci_bad:
        print("\nWARNING: SCIENCE paths with no parsable JD (first 5):")
        for p in sci_bad[:5]:
            print("  ", p)

    if dark_bad:
        print("\nWARNING: DARK paths with no parsable JD (first 5):")
        for p in dark_bad[:5]:
            print("  ", p)

    os.makedirs(args.out_dir, exist_ok=True)

    rows = []
    printed = 0
    expect_shape = (args.expect_ny, args.expect_nx)

    for sci in sci_items:
        before, after = find_bracketing(dark_jds, dark_items, sci.jd)

        if before is None or after is None:
            # Demo behaviour: record but don't write composite if bracketing is missing
            rows.append({
                "science_path": sci.path,
                "science_jd": f"{sci.jd:.10f}",
                "dark_before_path": "" if before is None else before.path,
                "dark_before_jd": "" if before is None else f"{before.jd:.10f}",
                "dt_before_seconds": "",
                "dark_after_path": "" if after is None else after.path,
                "dark_after_jd": "" if after is None else f"{after.jd:.10f}",
                "dt_after_seconds": "",
                "composite_dark_path": "",
                "status": "NO_BRACKET",
            })
            if args.max_print != 0 and printed < args.max_print:
                print("\nSCIENCE:")
                print(f"  {sci.path}")
                print(f"  JD={sci.jd:.10f}")
                print("  -> NO_BRACKET (missing before or after DARK)")
                printed += 1
            continue

        dtb = before.jd - sci.jd  # negative
        dta = after.jd - sci.jd   # positive

        # Read darks and create composite
        try:
            dimg_b, _ = read_fits_as_2d(before.path, expect_shape=expect_shape)
            dimg_a, _ = read_fits_as_2d(after.path, expect_shape=expect_shape)
            comp = 0.5 * (dimg_b + dimg_a)
        except Exception as e:
            rows.append({
                "science_path": sci.path,
                "science_jd": f"{sci.jd:.10f}",
                "dark_before_path": before.path,
                "dark_before_jd": f"{before.jd:.10f}",
                "dt_before_seconds": f"{days_to_seconds(dtb):.3f}",
                "dark_after_path": after.path,
                "dark_after_jd": f"{after.jd:.10f}",
                "dt_after_seconds": f"{days_to_seconds(dta):.3f}",
                "composite_dark_path": "",
                "status": f"READ_FAIL: {e}",
            })
            if args.max_print != 0 and printed < args.max_print:
                print("\nSCIENCE:")
                print(f"  {sci.path}")
                print(f"  JD={sci.jd:.10f}")
                print("DARK before:")
                print(f"  {before.path}")
                print(f"  dt={fmt_dt(dtb)}")
                print("DARK after:")
                print(f"  {after.path}")
                print(f"  dt={fmt_dt(dta)}")
                print(f"  -> READ_FAIL: {e}")
                printed += 1
            continue

        out_comp = make_out_name(sci.path, args.out_dir, suffix="_DARKCOMP")
        write_composite_dark(out_comp, comp, sci.path, sci.jd, before, after, dtb, dta)

        rows.append({
            "science_path": sci.path,
            "science_jd": f"{sci.jd:.10f}",
            "dark_before_path": before.path,
            "dark_before_jd": f"{before.jd:.10f}",
            "dt_before_days": f"{dtb:.10f}",
            "dt_before_seconds": f"{days_to_seconds(dtb):.3f}",
            "dark_after_path": after.path,
            "dark_after_jd": f"{after.jd:.10f}",
            "dt_after_days": f"{dta:.10f}",
            "dt_after_seconds": f"{days_to_seconds(dta):.3f}",
            "composite_dark_path": out_comp,
            "status": "OK",
        })

        if args.max_print != 0 and printed < args.max_print:
            print("\nSCIENCE:")
            print(f"  {sci.path}")
            print(f"  JD={sci.jd:.10f}")
            print("DARK before:")
            print(f"  {before.path}")
            print(f"  JD={before.jd:.10f}   dt={fmt_dt(dtb)}")
            print("DARK after:")
            print(f"  {after.path}")
            print(f"  JD={after.jd:.10f}   dt={fmt_dt(dta)}")
            print("COMPOSITE:")
            print(f"  {out_comp}")
            printed += 1

    # CSV
    if rows:
        with open(args.csv_out, "w", newline="", encoding="utf-8") as f:
            fieldnames = list(rows[0].keys())
            w = csv.DictWriter(f, fieldnames=fieldnames)
            w.writeheader()
            for r in rows:
                w.writerow(r)

        print(f"\nWrote CSV: {args.csv_out} (rows={len(rows)})")

    print("\nDONE.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

