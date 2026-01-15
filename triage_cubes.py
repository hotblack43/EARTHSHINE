#!/usr/bin/env python3
from __future__ import annotations

import argparse
import shlex
from pathlib import Path
from typing import List, Optional, Tuple

import numpy as np
from astropy.io import fits
import matplotlib.pyplot as plt


def load_cube_first_hdu(path: Path) -> np.ndarray:
    with fits.open(path) as hdul:
        data = hdul[0].data
    if data is None:
        raise ValueError("No data in primary HDU")
    arr = np.asarray(data)
    if arr.ndim != 3:
        raise ValueError(f"Expected a 3D cube, got shape={arr.shape}")
    return arr


def extract_layer(cube: np.ndarray, layer_1based: int) -> np.ndarray:
    """
    Return 2D image for the requested layer. Handles (nl,ny,nx) and (ny,nx,nl).
    """
    li = layer_1based - 1
    if li < 0:
        raise ValueError("layer must be >= 1")

    # Heuristic: layer axis is smallest dimension
    layer_axis = int(np.argmin(cube.shape))

    if layer_axis == 0:
        if li >= cube.shape[0]:
            raise IndexError(f"Layer {layer_1based} out of range (nl={cube.shape[0]})")
        img = cube[li, :, :]
    elif layer_axis == 2:
        if li >= cube.shape[2]:
            raise IndexError(f"Layer {layer_1based} out of range (nl={cube.shape[2]})")
        img = cube[:, :, li]
    elif layer_axis == 1:
        if li >= cube.shape[1]:
            raise IndexError(f"Layer {layer_1based} out of range (nl={cube.shape[1]})")
        img = cube[:, li, :]
    else:
        raise ValueError(f"Unsupported cube shape {cube.shape}")

    img = np.asarray(img, dtype=np.float32)
    if img.ndim != 2:
        raise ValueError(f"Layer extraction failed, got shape {img.shape}")
    return img


def percentile_stretch(img: np.ndarray, p_lo: float = 1.0, p_hi: float = 99.0) -> np.ndarray:
    x = img.astype(np.float32, copy=False)
    finite = np.isfinite(x)
    if not np.any(finite):
        return np.zeros_like(x)

    lo = np.nanpercentile(x[finite], p_lo)
    hi = np.nanpercentile(x[finite], p_hi)
    if not np.isfinite(lo) or not np.isfinite(hi) or hi <= lo:
        return np.zeros_like(x)

    y = (x - lo) / (hi - lo)
    y = np.clip(y, 0.0, 1.0)
    return y


def log_stretch(img: np.ndarray, p_lo: float = 1.0, p_hi: float = 99.5) -> np.ndarray:
    """
    Log stretch with robust floor so negative / tiny values don't explode.
    Steps:
      - subtract a low percentile floor
      - clamp to >=0
      - log1p
      - normalise by high percentile of log image
    """
    x = img.astype(np.float32, copy=False)
    finite = np.isfinite(x)
    if not np.any(finite):
        return np.zeros_like(x)

    floor = np.nanpercentile(x[finite], p_lo)
    x2 = x - floor
    x2 = np.where(np.isfinite(x2), x2, 0.0)
    x2 = np.maximum(x2, 0.0)

    y = np.log1p(x2)  # log(1+x)
    finite2 = np.isfinite(y)
    if not np.any(finite2):
        return np.zeros_like(y)

    hi = np.nanpercentile(y[finite2], p_hi)
    if not np.isfinite(hi) or hi <= 0:
        return np.zeros_like(y)

    y = y / hi
    y = np.clip(y, 0.0, 1.0)
    return y


def read_list_file(list_path: Path) -> List[str]:
    lines = list_path.read_text(encoding="utf-8").splitlines()
    out = []
    for ln in lines:
        ln = ln.strip()
        if not ln or ln.startswith("#"):
            continue
        out.append(ln)
    return out


def choose_files(indir: Path, glob_pat: str, list_file: Optional[Path]) -> List[Path]:
    if list_file is None:
        return sorted(indir.glob(glob_pat))

    names = read_list_file(list_file)
    paths: List[Path] = []
    for name in names:
        p = Path(name)
        if not p.is_absolute():
            p = indir / p
        paths.append(p)
    return paths


def mv_command(src: Path, bad_dir: Path) -> str:
    # -n = no clobber (GNU mv); OK if you prefer plain mv, remove -n
    return f"mkdir -p {shlex.quote(str(bad_dir))} && mv -n {shlex.quote(str(src))} {shlex.quote(str(bad_dir))}/"


def show_two_views(img: np.ndarray, title: str) -> None:
    lin = percentile_stretch(img, 1, 99)
    logv = log_stretch(img, 1, 99.7)

    plt.clf()
    fig = plt.gcf()
    fig.suptitle(title, fontsize=10)

    ax1 = plt.subplot(1, 2, 1)
    ax1.imshow(lin, origin="lower")
    ax1.set_title("Percentile stretch (1–99%)", fontsize=9)
    ax1.axis("off")

    ax2 = plt.subplot(1, 2, 2)
    ax2.imshow(logv, origin="lower")
    ax2.set_title("Log stretch (robust)", fontsize=9)
    ax2.axis("off")

    plt.tight_layout()


def get_keypress_blocking() -> str:
    """
    Block until a key is pressed while the figure is focused.
    Returns key string like '+', '-', 'q', etc.
    """
    key_holder = {"key": None}

    def on_key(event):
        key_holder["key"] = event.key

    cid = plt.gcf().canvas.mpl_connect("key_press_event", on_key)

    # Busy-wait with GUI event processing
    while key_holder["key"] is None:
        plt.pause(0.05)

    plt.gcf().canvas.mpl_disconnect(cid)
    return str(key_holder["key"])


def main() -> int:
    ap = argparse.ArgumentParser(description="Interactive inspection of cubes for streaky edge artifacts.")
    ap.add_argument("--indir", type=str, default="OUTPUT/COMBINED", help="Directory with FITS cubes.")
    ap.add_argument("--glob", type=str, default="*.fit*", help="Glob for cubes when --list not provided.")
    ap.add_argument("--list", type=str, default="", help="Optional text file of filenames to inspect (one per line).")
    ap.add_argument("--layer", type=int, default=1, help="Cube layer to display (1-based). Default: 1.")
    ap.add_argument("--bad-dir", type=str, default="OUTPUT/COMBINED/BAD", help="Where BAD cubes should be moved to.")
    ap.add_argument("--out-good", type=str, default="OUTPUT/COMBINED/good_images.txt",
                    help="Write GOOD filenames here.")
    ap.add_argument("--out-bad-cmds", type=str, default="OUTPUT/COMBINED/move_bad_images.sh",
                    help="Write BAD mv-commands here.")
    ap.add_argument("--start", type=int, default=1, help="Start index (1-based) into the file list.")
    args = ap.parse_args()

    indir = Path(args.indir)
    bad_dir = Path(args.bad_dir)
    out_good = Path(args.out_good)
    out_bad_cmds = Path(args.out_bad_cmds)

    list_file = Path(args.list) if args.list.strip() else None
    files = choose_files(indir, args.glob, list_file)

    if not files:
        print(f"ERROR: no files to inspect (indir={indir.resolve()}, glob={args.glob}, list={args.list!r})")
        return 2

    # Clamp start
    idx = max(0, int(args.start) - 1)
    if idx >= len(files):
        idx = 0

    good: List[str] = []
    bad_cmds: List[str] = []

    print("\nControls:")
    print("  '+'  = mark GOOD (keep)")
    print("  '-'  = mark BAD  (add mv command)")
    print("  's'  = skip (no decision)")
    print("  'b'  = back one image")
    print("  'q'  = quit and write lists\n")

    plt.figure(figsize=(10, 5))

    while 0 <= idx < len(files):
        p = files[idx]
        if not p.exists():
            print(f"[{idx+1}/{len(files)}] MISSING: {p}")
            idx += 1
            continue

        try:
            cube = load_cube_first_hdu(p)
            img = extract_layer(cube, args.layer)
        except Exception as e:
            print(f"[{idx+1}/{len(files)}] ERROR reading {p.name}: {e}")
            idx += 1
            continue

        title = f"[{idx+1}/{len(files)}] {p.name}   (layer {args.layer})   (+ good, - bad, s skip, b back, q quit)"
        show_two_views(img, title)

        key = get_keypress_blocking()

        if key == "+":
            good.append(p.name)
            print(f"GOOD: {p.name}")
            idx += 1
        elif key == "-":
            cmd = mv_command(p, bad_dir)
            bad_cmds.append(cmd)
            print(f"BAD : {p.name}")
            idx += 1
        elif key.lower() == "s":
            print(f"SKIP: {p.name}")
            idx += 1
        elif key.lower() == "b":
            idx = max(0, idx - 1)
            print("BACK")
        elif key.lower() == "q":
            print("QUIT")
            break
        else:
            # Ignore unknown keys; keep same image
            print(f"(ignored key {key!r}) — use +, -, s, b, q")

    # Write outputs
    out_good.parent.mkdir(parents=True, exist_ok=True)
    out_bad_cmds.parent.mkdir(parents=True, exist_ok=True)
    out_good.write_text("\n".join(good) + ("\n" if good else ""), encoding="utf-8")
    out_bad_cmds.write_text("\n".join(bad_cmds) + ("\n" if bad_cmds else ""), encoding="utf-8")

    print("\nWrote:")
    print(f"  GOOD list: {out_good.resolve()}  ({len(good)} entries)")
    print(f"  BAD cmds : {out_bad_cmds.resolve()}  ({len(bad_cmds)} commands)")
    print("\nTo execute the move commands:")
    print(f"  bash {shlex.quote(str(out_bad_cmds))}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())

