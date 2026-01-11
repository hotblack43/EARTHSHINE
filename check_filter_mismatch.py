#!/usr/bin/env python3
"""
check_filter_mismatch.py

Compare filter name inferred from filename vs filter recorded in FITS header.

Examples:
  uv run check_filter_mismatch.py --file /path/to/2455912.1834295MOON_V_AIR.fits.gz

  uv run check_filter_mismatch.py --list allJDsFromImages.txt

Exit code:
  0  if all checked files match
  2  if one or more mismatches are found
  1  for I/O or other errors
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from typing import Iterable, List, Optional, Tuple

from astropy.io import fits


# ---------------------------
# Parsing helpers
# ---------------------------

# Accept these known filter tokens from filename after "MOON_"
KNOWN_FILTERS = {"B", "V", "IRCUT", "VE1", "VE2", "IR", "R", "G"}  # extend if needed


def filter_from_filename(path: str) -> Optional[str]:
    """
    Extract filter token from filenames like:
      .../2455912.1834295MOON_V_AIR.fits.gz
      .../2456017.7259254MOON_VE1_AIR.fits.gz
      .../245xxxx.xxxxxxxMOON_IRCUT_AIR.fits.gz

    Returns token like "V", "VE2", "IRCUT" or None if not found.
    """
    base = os.path.basename(path)

    # Find "...MOON_<TOKEN>_" where TOKEN is letters/numbers
    m = re.search(r"MOON_([A-Za-z0-9]+)_", base)
    if not m:
        return None

    tok = m.group(1).upper().strip()
    # Normalise common variations (if any show up later)
    tok = tok.replace("-", "").replace(" ", "")
    return tok


def filter_from_header(hdr: fits.Header, key: str) -> Optional[str]:
    """
    Read filter token from header key and normalise.
    """
    if key in hdr:
        v = hdr.get(key)
    else:
        # Some FITS writers might store it without HIERARCH prefix (rare)
        v = None

    if v is None:
        return None

    s = str(v).strip().upper()
    s = s.replace("\x00", "").strip()
    # Many cameras write fixed-width strings with padding
    s = s.strip()
    return s if s != "" else None


def load_header(path: str) -> fits.Header:
    """
    Load primary header from FITS or FITS.GZ.
    """
    # fits.open handles .gz transparently
    with fits.open(path, memmap=False) as hdul:
        return hdul[0].header


# ---------------------------
# Main checking
# ---------------------------

def iter_paths_from_listfile(listfile: str) -> Iterable[str]:
    with open(listfile, "r", encoding="utf-8") as f:
        for line in f:
            p = line.strip()
            if not p or p.startswith("#"):
                continue
            yield p


def check_one(path: str, header_key: str, strict_known: bool) -> Tuple[bool, str]:
    """
    Returns (ok, message). ok=False means mismatch or missing info.
    """
    fn_filt = filter_from_filename(path)

    try:
        hdr = load_header(path)
    except Exception as e:
        return (False, f"ERROR: cannot read header: {e}")

    hdr_filt = filter_from_header(hdr, header_key)

    # Optional: complain if filename token is not in known set
    if strict_known and fn_filt is not None and fn_filt not in KNOWN_FILTERS:
        return (False, f"WARNING: filename filter '{fn_filt}' not in KNOWN_FILTERS={sorted(KNOWN_FILTERS)}")

    # Compare
    if fn_filt is None and hdr_filt is None:
        return (False, "WARNING: no filter found in filename AND no header filter found")
    if fn_filt is None:
        return (False, f"WARNING: no filter found in filename; header says '{hdr_filt}'")
    if hdr_filt is None:
        return (False, f"WARNING: filename says '{fn_filt}'; header key {header_key} missing/blank")
    if fn_filt != hdr_filt:
        return (False, f"WARNING: MISMATCH filename='{fn_filt}' header='{hdr_filt}'")

    return (True, f"OK: filter='{fn_filt}'")


def main() -> int:
    ap = argparse.ArgumentParser(
        description="Compare filter token from filename vs FITS header and print WARNING on mismatch."
    )
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--file", help="One FITS/FITS.GZ file to check")
    g.add_argument("--list", help="Text file containing one FITS/FITS.GZ path per line")
    ap.add_argument(
        "--header-key",
        default="HIERARCH DMI_COLOR_FILTER",
        help="Header keyword to read filter from (default: HIERARCH DMI_COLOR_FILTER)",
    )
    ap.add_argument(
        "--strict-known",
        action="store_true",
        help="Warn if filename filter token is not in the built-in KNOWN_FILTERS set",
    )
    args = ap.parse_args()

    paths: List[str] = []
    if args.file:
        paths = [args.file]
    else:
        paths = list(iter_paths_from_listfile(args.list))

    n_total = 0
    n_ok = 0
    n_bad = 0

    for p in paths:
        n_total += 1
        print(f"FILE {n_total:05d}: {p}")
        ok, msg = check_one(p, header_key=args.header_key, strict_known=bool(args.strict_known))
        print(f"  {msg}")
        if ok:
            n_ok += 1
        else:
            n_bad += 1

    print(f"\nSUMMARY: total={n_total} ok={n_ok} warnings/errors={n_bad}")

    # Exit code 2 if any mismatch/warning/error was found
    return 0 if n_bad == 0 else 2


if __name__ == "__main__":
    raise SystemExit(main())

