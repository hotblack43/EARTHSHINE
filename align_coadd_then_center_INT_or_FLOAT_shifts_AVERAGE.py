#!/usr/bin/env python3
#
#
# uv run align_coadd_then_center_INT_or_FLOAT_shifts_AVERAGE.py --align-iters 2 --r-min 125 --r-max 150 --verbose
#
from __future__ import annotations

import argparse
import os
import sys
from datetime import datetime, timezone
from typing import List, Optional, Tuple

import numpy as np
from astropy.io import fits

# Optional dependencies for subpixel mode
HAVE_SCIPY = False
HAVE_SKIMAGE = False
try:
    import scipy.ndimage as ndi  # type: ignore
    HAVE_SCIPY = True
except Exception:
    HAVE_SCIPY = False

try:
    from skimage.registration import phase_cross_correlation  # type: ignore
    HAVE_SKIMAGE = True
except Exception:
    HAVE_SKIMAGE = False


# ---------------------------
# I/O and frame iteration
# ---------------------------

def read_file_list(list_path: str) -> List[str]:
    out: List[str] = []
    with open(list_path, "r", encoding="utf-8", errors="replace") as f:
        for line in f:
            s = line.strip()
            if not s or s.startswith("#"):
                continue
            out.append(os.path.abspath(os.path.expanduser(s)))
    return out


def choose_hdu_with_image(hdul: fits.HDUList) -> int:
    for i, hdu in enumerate(hdul):
        if hdu.data is None:
            continue
        a = np.asarray(hdu.data)
        if a.ndim in (2, 3):
            return i
    raise RuntimeError("No 2D/3D image HDU found")


def iter_frames_expect_shape(
    path: str,
    hdu_index: Optional[int],
    expect_ny: int,
    expect_nx: int,
    max_frames_per_file: int,
    verbose: bool,
):
    """
    Yield frames as 2D arrays (ny,nx), from either:
      - 2D: (ny,nx)                 -> 1 frame
      - 3D: (ny,nx,n)               -> n frames (stack on last axis)
      - 3D: (n,ny,nx)               -> n frames (stack on first axis)
    """
    with fits.open(path, memmap=False) as hdul:
        hi = hdu_index if hdu_index is not None else choose_hdu_with_image(hdul)
        hdu = hdul[hi]
        data = np.asarray(hdu.data)
        hdr = hdu.header.copy()
        shape_raw = str(tuple(data.shape))
        dtype_str = str(data.dtype)

        if verbose:
            print(f"  Using HDU {hi}  raw shape={shape_raw}  dtype={dtype_str}")

        if data.ndim == 2:
            if data.shape != (expect_ny, expect_nx):
                raise RuntimeError(f"2D shape {data.shape} != {(expect_ny, expect_nx)}")
            if verbose:
                print("  Detected single-frame 2D FITS (no stack).")
            yield hi, data, hdr, 0, shape_raw, "ny,nx(2D)", dtype_str
            return

        if data.ndim != 3:
            raise RuntimeError(f"ndim={data.ndim} not supported; shape={data.shape}")

        # 3D: (ny,nx,n)
        if data.shape[0] == expect_ny and data.shape[1] == expect_nx:
            n = data.shape[2]
            if n > max_frames_per_file:
                raise RuntimeError(f"n_frames={n} > max_frames_per_file={max_frames_per_file} (shape={data.shape})")
            if verbose:
                print(f"  Detected layout ny,nx,n (stack on last axis). n_frames={n}")
            for k in range(n):
                yield hi, data[:, :, k], hdr, k, shape_raw, "ny,nx,n(last)", dtype_str
            return

        # 3D: (n,ny,nx)
        if data.shape[1] == expect_ny and data.shape[2] == expect_nx:
            n = data.shape[0]
            if n > max_frames_per_file:
                raise RuntimeError(f"n_frames={n} > max_frames_per_file={max_frames_per_file} (shape={data.shape})")
            if verbose:
                print(f"  Detected layout n,ny,nx (stack on first axis). n_frames={n}")
            for k in range(n):
                yield hi, data[k, :, :], hdr, k, shape_raw, "n,ny,nx(first)", dtype_str
            return

        raise RuntimeError(
            f"3D shape {data.shape} does not match (ny,nx,n) or (n,ny,nx) with ny,nx={(expect_ny, expect_nx)}"
        )


# ---------------------------
# Exposure selection (over-only)
# ---------------------------

def classify_overonly(img2d: np.ndarray, over_thresh: float, over_count: int, abundant_q: float) -> Tuple[str, dict, str]:
    a = np.asarray(img2d)
    if a.ndim != 2:
        return "BAD", {}, "not_2d"
    finite = np.isfinite(a)
    if not finite.any():
        return "BAD", {}, "no_finite_pixels"

    af = a[finite]
    mx = float(np.max(af))
    n_total = int(af.size)
    n_over = int(np.count_nonzero(af >= over_thresh))
    abund = float(np.quantile(af, abundant_q))

    if n_over >= over_count:
        return "OVER", {"max": mx, "abundant_max": abund, "n_over": n_over, "n_total": n_total}, ""
    return "OK", {"max": mx, "abundant_max": abund, "n_over": n_over, "n_total": n_total}, ""


# ---------------------------
# Shifts: integer cyclic (np.roll) or subpixel cyclic (ndimage.shift mode='wrap')
# ---------------------------

def apply_shift_cyclic(img2d: np.ndarray, dy: float, dx: float, subpixel: bool, order: int) -> np.ndarray:
    """
    Apply a cyclic (wrap-around) shift.
      - integer mode: np.roll with nearest integer shift
      - subpixel mode: scipy.ndimage.shift with mode='wrap' and spline order (default 3)
    """
    if not subpixel:
        iy = int(np.rint(dy))
        ix = int(np.rint(dx))
        return np.roll(img2d, shift=(iy, ix), axis=(0, 1)).astype(np.float32, copy=False)

    if not HAVE_SCIPY:
        raise RuntimeError("Subpixel shifting requested but SciPy is not available. Install with: uv add scipy")

    # NOTE: ndi.shift uses (shift_y, shift_x). mode='wrap' makes it cyclic.
    # order=3 (cubic) generally avoids the 'ladder/nylons' look better than Fourier shifting.
    out = ndi.shift(img2d.astype(np.float32, copy=False), shift=(dy, dx), order=int(order), mode="wrap", prefilter=True)
    return out.astype(np.float32, copy=False)


# ---------------------------
# Alignment via phase correlation (integer) OR skimage phase_cross_correlation (subpixel)
# ---------------------------

def phase_correlation_shift_int(ref: np.ndarray, img: np.ndarray, eps: float = 1e-12) -> Tuple[int, int, float]:
    """
    Estimate integer cyclic shift (dy,dx) that aligns img to ref using phase correlation.
    Returns (dy, dx, peak_value).
    Convention: apply np.roll(img, shift=(dy,dx)) to best align to ref.
    """
    a = ref.astype(np.float32, copy=False)
    b = img.astype(np.float32, copy=False)

    Fa = np.fft.fft2(a)
    Fb = np.fft.fft2(b)
    R = Fa * np.conj(Fb)
    R /= (np.abs(R) + eps)
    c = np.fft.ifft2(R).real

    iy, ix = np.unravel_index(np.argmax(c), c.shape)
    peak = float(c[iy, ix])

    ny, nx = c.shape
    dy = int(iy)
    dx = int(ix)
    if dy > ny // 2:
        dy -= ny
    if dx > nx // 2:
        dx -= nx

    return dy, dx, peak


def phase_correlation_shift_subpixel(ref: np.ndarray, img: np.ndarray, upsample_factor: int) -> Tuple[float, float, float]:
    """
    Subpixel shift estimate using skimage.registration.phase_cross_correlation.
    Returns (dy, dx, error_metric).
    Convention: apply shift (dy,dx) to img to best align to ref.
    """
    if not HAVE_SKIMAGE:
        raise RuntimeError("Subpixel alignment requested but scikit-image is not available. Install with: uv add scikit-image")
    # phase_cross_correlation returns shift vector such that shifting img by that aligns to ref.
    shift, error, _phasediff = phase_cross_correlation(
        ref.astype(np.float32, copy=False),
        img.astype(np.float32, copy=False),
        upsample_factor=int(upsample_factor),
        normalization="phase",
    )
    dy = float(shift[0])
    dx = float(shift[1])
    return dy, dx, float(error)


def align_stack_iterative(
    frames: List[np.ndarray],
    n_iters: int,
    verbose: bool,
    subpixel: bool,
    subpix_upsample: int,
    subpix_order: int,
) -> Tuple[List[np.ndarray], List[Tuple[float, float]], np.ndarray]:
    """
    Iteratively align frames to a reference that is updated as the coadd.

    Default (subpixel=False):
      - integer cyclic shifts via np.roll (no interpolation artefacts)

    Subpixel (subpixel=True):
      - estimate shifts via skimage phase_cross_correlation (upsampled peak)
      - apply shifts via scipy.ndimage.shift(order=3, mode='wrap') to avoid FFT ringing
      - NOTE: iterative subpixel alignment resamples more than once. Keep n_iters small (1-2).
    """
    if not frames:
        raise RuntimeError("No frames to align")

    ref = frames[0].astype(np.float32, copy=False)
    aligned = [f.astype(np.float32, copy=False) for f in frames]
    shifts: List[Tuple[float, float]] = [(0.0, 0.0) for _ in frames]

    n_iters_eff = max(1, int(n_iters))
    if subpixel and n_iters_eff > 2 and verbose:
        print("  NOTE: subpixel mode with >2 iterations may introduce extra interpolation blur; consider --align-iters 1 or 2.")

    for it in range(n_iters_eff):
        if verbose:
            mode = "subpixel" if subpixel else "integer"
            print(f"  ALIGN iter {it+1}/{n_iters_eff} ({mode}): computing shifts to current reference/coadd")

        new_aligned: List[np.ndarray] = []
        new_shifts: List[Tuple[float, float]] = []

        for i, fr in enumerate(aligned):
            if subpixel:
                dy, dx, err = phase_correlation_shift_subpixel(ref, fr, upsample_factor=subpix_upsample)
                fr2 = apply_shift_cyclic(fr, dy=dy, dx=dx, subpixel=True, order=subpix_order)
                if verbose and (i == 0 or i % 10 == 0):
                    print(f"    frame {i:03d}: shift dy={dy:+.3f} dx={dx:+.3f}  err={err:.4g}")
            else:
                dy_i, dx_i, peak = phase_correlation_shift_int(ref, fr)
                dy = float(dy_i)
                dx = float(dx_i)
                fr2 = apply_shift_cyclic(fr, dy=dy, dx=dx, subpixel=False, order=0)
                if verbose and (i == 0 or i % 10 == 0):
                    print(f"    frame {i:03d}: shift dy={int(dy):+d} dx={int(dx):+d}  peak={peak:.4f}")

            new_aligned.append(fr2)
            new_shifts.append((dy, dx))

        aligned = new_aligned
        shifts = new_shifts
        ref = np.mean(np.stack(aligned, axis=0), axis=0).astype(np.float32, copy=False)

    coadd = ref
    return aligned, shifts, coadd


# ---------------------------
# RANSAC limb → inliers → LS circle fit
# ---------------------------

def sobel_gradmag(a: np.ndarray) -> np.ndarray:
    a = a.astype(np.float32, copy=False)
    p = np.pad(a, 1, mode="edge")
    gx = (
        -1 * p[0:-2, 0:-2] + 1 * p[0:-2, 2:] +
        -2 * p[1:-1, 0:-2] + 2 * p[1:-1, 2:] +
        -1 * p[2:  , 0:-2] + 1 * p[2:  , 2:]
    )
    gy = (
        -1 * p[0:-2, 0:-2] + -2 * p[0:-2, 1:-1] + -1 * p[0:-2, 2:] +
         1 * p[2:  , 0:-2] +  2 * p[2:  , 1:-1] +  1 * p[2:  , 2:]
    )
    return np.sqrt(gx * gx + gy * gy)


def circle_from_3pts(p1: Tuple[float, float], p2: Tuple[float, float], p3: Tuple[float, float]) -> Optional[Tuple[float, float, float]]:
    x1, y1 = p1
    x2, y2 = p2
    x3, y3 = p3
    d = 2.0 * (x1*(y2 - y3) + x2*(y3 - y1) + x3*(y1 - y2))
    if abs(d) < 1e-6:
        return None
    x1sq = x1*x1 + y1*y1
    x2sq = x2*x2 + y2*y2
    x3sq = x3*x3 + y3*y3
    cx = (x1sq*(y2 - y3) + x2sq*(y3 - y1) + x3sq*(y1 - y2)) / d
    cy = (x1sq*(x3 - x2) + x2sq*(x1 - x3) + x3sq*(x2 - x1)) / d
    r = np.sqrt((cx - x1)**2 + (cy - y1)**2)
    if not np.isfinite(r):
        return None
    return float(cx), float(cy), float(r)


def fit_circle_least_squares(xs: np.ndarray, ys: np.ndarray) -> Tuple[float, float, float]:
    x = xs.astype(np.float64, copy=False)
    y = ys.astype(np.float64, copy=False)
    A = np.column_stack([2*x, 2*y, np.ones_like(x)])
    b = x*x + y*y
    sol, *_ = np.linalg.lstsq(A, b, rcond=None)
    cx, cy, c = sol
    r2 = cx*cx + cy*cy + c
    if not np.isfinite(r2) or r2 <= 0:
        raise RuntimeError("LS circle fit invalid")
    r = float(np.sqrt(r2))
    return float(cx), float(cy), float(r)


def ransac_then_fit_circle(
    img2d: np.ndarray,
    r_min: float,
    r_max: float,
    grad_keep: int,
    iters: int,
    inlier_tol: float,
    min_inliers: int,
    abundant_q: float,
    verbose: bool,
) -> Tuple[float, float, float, int]:
    """
    Candidate edge points from gradients -> RANSAC circle -> inlier set -> LS circle fit on inliers.
    """
    a = img2d.astype(np.float32, copy=False)
    finite = np.isfinite(a)
    if finite.any():
        hi = float(np.quantile(a[finite], abundant_q))
        if np.isfinite(hi) and hi > 0:
            a = np.clip(a, 0, hi)

    g = sobel_gradmag(a)
    flat = g.ravel()
    ny, nx = a.shape

    if grad_keep >= flat.size:
        idx = np.argsort(flat)[::-1]
    else:
        idx_part = np.argpartition(flat, -grad_keep)[-grad_keep:]
        idx = idx_part[np.argsort(flat[idx_part])[::-1]]

    ys = (idx // nx).astype(np.int32)
    xs = (idx % nx).astype(np.int32)

    px = xs.astype(np.float32)
    py = ys.astype(np.float32)
    n_pts = px.size
    if n_pts < 3:
        raise RuntimeError("Not enough edge candidates")

    rng = np.random.default_rng(12345)
    best_inliers = -1
    best_model: Optional[Tuple[float, float, float]] = None

    for _ in range(int(iters)):
        i1, i2, i3 = rng.integers(0, n_pts, size=3)
        if i1 == i2 or i1 == i3 or i2 == i3:
            continue
        m = circle_from_3pts((px[i1], py[i1]), (px[i2], py[i2]), (px[i3], py[i3]))
        if m is None:
            continue
        cx, cy, r = m
        if not (r_min <= r <= r_max):
            continue
        d = np.sqrt((px - cx)**2 + (py - cy)**2)
        nin = int(np.count_nonzero(np.abs(d - r) <= inlier_tol))
        if nin > best_inliers:
            best_inliers = nin
            best_model = (cx, cy, r)

    if best_model is None or best_inliers < int(min_inliers):
        raise RuntimeError(f"RANSAC failed (best_inliers={best_inliers}, min_inliers={min_inliers})")

    cx0, cy0, r0 = best_model
    d0 = np.sqrt((px - cx0)**2 + (py - cy0)**2)
    mask = np.abs(d0 - r0) <= inlier_tol
    nin = int(np.count_nonzero(mask))
    if nin < 10:
        raise RuntimeError("Too few inliers after RANSAC")

    cx, cy, r = fit_circle_least_squares(px[mask], py[mask])
    if not (r_min <= r <= r_max):
        raise RuntimeError(f"LS radius out of bounds: r={r:.2f}")

    if verbose:
        print(f"  COADD circle (RANSAC->LS): cx={cx:.2f} cy={cy:.2f} r={r:.2f} inliers={nin}")

    return cx, cy, r, nin


# ---------------------------
# FITS writing
# ---------------------------

def make_output_path(in_path: str, out_dir: str, suffix: str) -> str:
    base = os.path.basename(in_path)
    if base.lower().endswith(".gz"):
        base = base[:-3]
    for ext in (".fits", ".fit", ".fts"):
        if base.lower().endswith(ext):
            base = base[: -len(ext)]
            break
    out_name = f"{base}{suffix}.fits"
    return os.path.join(out_dir, out_name)


def write_centered_cube(
    out_fits: str,
    cube_nyx: np.ndarray,
    hdr0: fits.Header,
    discrad: float,
    n_ok: int,
    verbose: bool,
    align_mode: str,
    center_mode: str,
    subpix_upsample: int,
    subpix_order: int,
) -> None:
    """
    cube_nyx must be shape (n,ny,nx)
    """
    hdr = hdr0.copy()
    hdr["NOK"] = (int(n_ok), "Number of acceptable frames used")
    hdr["DISCRAD"] = (float(discrad), "Disc radius [px] from coadd fit")
    now = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    hdr.add_history(f"Aligned+centred cube written {now}")
    hdr.add_history(f"Alignment mode: {align_mode}")
    hdr.add_history(f"Centring mode:  {center_mode}")
    if "subpixel" in align_mode or "subpixel" in center_mode:
        hdr.add_history(f"Subpixel: upsample_factor={int(subpix_upsample)} spline_order={int(subpix_order)} mode=wrap")
    else:
        hdr.add_history("Shift is integer cyclic (np.roll)")

    os.makedirs(os.path.dirname(out_fits) or ".", exist_ok=True)
    fits.PrimaryHDU(data=cube_nyx.astype(np.float32, copy=False), header=hdr).writeto(out_fits, overwrite=True)

    print(f"  Wrote centred cube: {out_fits}")
    print(f"    shape={cube_nyx.shape} dtype=float32 NOK={n_ok} DISCRAD={discrad:.3f}")
    if verbose:
        print("    NOTE: cube stored as (n,ny,nx) so FITS NAXIS3=n_frames")

def write_averaged_image(
    out_fits: str,
    img2d: np.ndarray,
    hdr0: fits.Header,
    discrad: float,
    n_ok: int,
    verbose: bool,
    align_mode: str,
    center_mode: str,
    subpix_upsample: int,
    subpix_order: int,
) -> None:
    """
    Write a single averaged 2D image (ny,nx) to FITS.
    """
    if img2d.ndim != 2:
        raise RuntimeError(f"Averaged image must be 2D, got shape={img2d.shape}")

    hdr = hdr0.copy()
    hdr["NOK"] = (int(n_ok), "Number of acceptable frames averaged")
    hdr["DISCRAD"] = (float(discrad), "Disc radius [px] from coadd fit")

    now = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    hdr.add_history(f"Averaged centred image written {now}")
    hdr.add_history(f"Alignment mode: {align_mode}")
    hdr.add_history(f"Centring mode:  {center_mode}")
    hdr.add_history("Image is mean of centred frames")

    if "subpixel" in align_mode or "subpixel" in center_mode:
        hdr.add_history(
            f"Subpixel: upsample_factor={int(subpix_upsample)} "
            f"spline_order={int(subpix_order)} mode=wrap"
        )
    else:
        hdr.add_history("Shift is integer cyclic (np.roll)")

    os.makedirs(os.path.dirname(out_fits) or ".", exist_ok=True)
    fits.PrimaryHDU(
        data=img2d.astype(np.float32, copy=False),
        header=hdr
    ).writeto(out_fits, overwrite=True)

    print(f"  Wrote averaged image: {out_fits}")
    print(f"    shape={img2d.shape} dtype=float32 NOK={n_ok} DISCRAD={discrad:.3f}")


# ---------------------------
# Main
# ---------------------------

def main() -> int:
    ap = argparse.ArgumentParser(
        description=(
            "Align frames by correlation, coadd, detect disc on coadd, then centre all frames by one shift.\n"
            "Default: integer cyclic shifts (np.roll).\n"
            "Optional: --subpixel to enable subpixel alignment (skimage) + subpixel shifting (scipy.ndimage.shift, mode='wrap')."
        )
    )
    ap.add_argument("--list", default="MLO_imagefiles.txt")
    ap.add_argument("--out-dir", default="CENTERED")
    ap.add_argument("--suffix", default="_ALIGNED_CENTERED")
    ap.add_argument("--hdu", type=int, default=None)

    ap.add_argument("--ny", type=int, default=512)
    ap.add_argument("--nx", type=int, default=512)
    ap.add_argument("--max-frames-per-file", type=int, default=100)

    ap.add_argument("--over-thresh", type=float, default=55000.0)
    ap.add_argument("--over-count", type=int, default=1000)
    ap.add_argument("--abundant-q", type=float, default=0.999)

    # Alignment
    ap.add_argument("--align-iters", type=int, default=2, help="Number of iterative alignment passes per file (1-4 typical).")

    # Subpixel mode
    ap.add_argument("--subpixel", action="store_true",
                    help="Enable subpixel alignment and shifting (requires scipy + scikit-image).")
    ap.add_argument("--subpix-upsamp", type=int, default=50,
                    help="Upsampling factor for phase_cross_correlation peak refinement (subpixel mode).")
    ap.add_argument("--subpix-order", type=int, default=3,
                    help="Spline order for scipy.ndimage.shift in subpixel mode (3=cubic; 1=linear; 0=nearest).")
    ap.add_argument("--center-subpixel", action="store_true",
                    help="Also apply the final centring shift as subpixel (default: follow --subpixel).")

    # Disc detection on coadd
    ap.add_argument("--r-min", type=float, default=110.0)
    ap.add_argument("--r-max", type=float, default=170.0)
    ap.add_argument("--grad-keep", type=int, default=30000)
    ap.add_argument("--ransac-iters", type=int, default=12000)
    ap.add_argument("--inlier-tol", type=float, default=2.5)
    ap.add_argument("--min-inliers", type=int, default=1500)

    ap.add_argument("--target-x", type=float, default=256.0)
    ap.add_argument("--target-y", type=float, default=256.0)

    ap.add_argument("--verbose", action="store_true")
    ap.add_argument("--print-every", type=int, default=10)
    args = ap.parse_args()

    if args.subpixel:
        if not HAVE_SKIMAGE or not HAVE_SCIPY:
            missing = []
            if not HAVE_SCIPY:
                missing.append("scipy")
            if not HAVE_SKIMAGE:
                missing.append("scikit-image")
            raise SystemExit(
                "ERROR: --subpixel requested but missing dependencies: "
                + ", ".join(missing)
                + ". Install with: uv add " + " ".join(missing)
            )

    paths = read_file_list(args.list)
    if not paths:
        print("Empty list.", file=sys.stderr)
        return 2

    os.makedirs(args.out_dir, exist_ok=True)

    n_files = len(paths)

    for fi, p in enumerate(paths, start=1):
        print(f"\nFILE {fi}/{n_files}: {p}")

        if not os.path.exists(p):
            print("  BAD: missing file")
            continue

        ok_frames: List[np.ndarray] = []
        hdr0: Optional[fits.Header] = None
        n_in_file = 0
        n_ok = 0

        try:
            for hdu_idx, frame2d, hdr, k, shape_raw, layout, dtype_str in iter_frames_expect_shape(
                p, args.hdu, args.ny, args.nx, args.max_frames_per_file, verbose=args.verbose
            ):
                n_in_file += 1
                if hdr0 is None:
                    hdr0 = hdr

                cls, stats, _note = classify_overonly(frame2d, args.over_thresh, args.over_count, args.abundant_q)

                if args.print_every > 0 and ((k % args.print_every == 0) or (cls in ("OVER", "BAD"))):
                    print(
                        f"  frame {k:03d} ({layout}) -> {cls:5s} "
                        f"max={stats.get('max', float('nan')):.0f} "
                        f"abund={stats.get('abundant_max', float('nan')):.0f} "
                        f"n_over={stats.get('n_over', 0)}"
                    )

                if cls == "OK":
                    ok_frames.append(frame2d.astype(np.float32, copy=False))
                    n_ok += 1

            if hdr0 is None:
                print("  BAD: no header/data found.")
                continue

            print(f"  Exposure selection: inspected={n_in_file} OK={n_ok}")

            if n_ok == 0:
                print("  No OK frames; skipping.")
                continue

            # 1) Align frames (integer default, optional subpixel)
            aligned, shifts, coadd = align_stack_iterative(
                ok_frames,
                n_iters=args.align_iters,
                verbose=args.verbose,
                subpixel=bool(args.subpixel),
                subpix_upsample=int(args.subpix_upsamp),
                subpix_order=int(args.subpix_order),
            )

            # 2) Disc detect on the coadd only
            cx, cy, r, nin = ransac_then_fit_circle(
                coadd,
                r_min=args.r_min, r_max=args.r_max,
                grad_keep=args.grad_keep,
                iters=args.ransac_iters,
                inlier_tol=args.inlier_tol,
                min_inliers=args.min_inliers,
                abundant_q=args.abundant_q,
                verbose=True,   # always print coadd disc result
            )

            # 3) Final centring shift applied to all aligned frames
            dx = args.target_x - cx
            dy = args.target_y - cy

            do_center_subpix = bool(args.center_subpixel) or bool(args.subpixel)
            if not do_center_subpix:
                ix = int(np.rint(dx))
                iy = int(np.rint(dy))
                print(f"  Centring shift from coadd: dx={dx:.3f}->{ix}  dy={dy:.3f}->{iy}  (integer cyclic)")
                centred = [apply_shift_cyclic(fr, dy=iy, dx=ix, subpixel=False, order=0) for fr in aligned]
                center_mode = "integer cyclic (np.roll)"
            else:
                print(f"  Centring shift from coadd: dx={dx:.3f}  dy={dy:.3f}  (subpixel, wrap, order={int(args.subpix_order)})")
                centred = [apply_shift_cyclic(fr, dy=dy, dx=dx, subpixel=True, order=int(args.subpix_order)) for fr in aligned]
                center_mode = f"subpixel (ndimage.shift wrap order={int(args.subpix_order)})"

# 4) Stack and average centred frames
            cube = np.stack(centred, axis=0)   # (n,ny,nx)
            avg = np.mean(cube, axis=0)        # (ny,nx)

            out_path = make_output_path(p, args.out_dir, args.suffix + "_AVG")

            align_mode = (
                "subpixel (skimage phase_cross_correlation)"
                if args.subpixel
                else "integer cyclic phase correlation"
            )

            write_averaged_image(
                out_path,
                avg,
                hdr0,
                discrad=r,
                n_ok=len(centred),
                verbose=args.verbose,
                align_mode=align_mode,
                center_mode=center_mode,
                subpix_upsample=int(args.subpix_upsamp),
                subpix_order=int(args.subpix_order),
            )

        except Exception as e:
            print(f"  BAD: exception: {e}", file=sys.stderr)
            continue

    print("\nDONE.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
