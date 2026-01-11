#!/usr/bin/env python3
#
#
# uv run align_coadd_then_center_INT_or_FLOAT_shifts_AVERAGE_SCI_DARK_DIFF_DARKFIRST.py --align-iters 2 --r-min 125 --r-max 150 --verbose
#
from __future__ import annotations

import argparse
import os
import sys
from datetime import datetime, timezone
from typing import List, Optional, Tuple

import numpy as np
from astropy.io import fits


# ---------------------------
# DARK bracketing + composite (from demo)
# ---------------------------

import bisect
import re
from dataclasses import dataclass

JD_RE = re.compile(r"(245\d{4,}\.\d+)")

@dataclass(frozen=True)
class JDFile:
    jd: float
    path: str

def parse_jd_from_path(p: str) -> Optional[float]:
    """
    Extract JD from filename/path. We look in the basename first, then full path.
    Expected pattern includes something like: 2456017.7238820....
    """
    base = os.path.basename(p)
    m = JD_RE.search(base)
    if m:
        return float(m.group(1))
    m = JD_RE.search(p)
    if m:
        return float(m.group(1))
    return None

def build_sorted_jd_files(paths: List[str], label: str) -> Tuple[List[float], List[JDFile], List[str]]:
    """
    Build sorted JD list for fast bracketing searches.

    Returns:
      - jds_sorted: List[float]
      - items_sorted: List[JDFile]
      - bad_paths: paths where JD could not be parsed
    """
    items: List[JDFile] = []
    bad: List[str] = []
    for p in paths:
        jd = parse_jd_from_path(p)
        if jd is None:
            bad.append(p)
            continue
        items.append(JDFile(jd=jd, path=p))
    items.sort(key=lambda x: x.jd)
    jds_sorted = [x.jd for x in items]
    if not items:
        raise RuntimeError(f"No parsable JDs found in {label} list.")
    return jds_sorted, items, bad

def find_bracketing(dark_jds: List[float], dark_items: List[JDFile], target_jd: float) -> Tuple[Optional[JDFile], Optional[JDFile]]:
    """
    Find the DARK strictly before and strictly after target_jd.
    """
    i = bisect.bisect_left(dark_jds, target_jd)
    before = dark_items[i - 1] if i - 1 >= 0 else None
    j = bisect.bisect_right(dark_jds, target_jd)
    after = dark_items[j] if j < len(dark_items) else None
    return before, after

def days_to_seconds(dt_days: float) -> float:
    return dt_days * 86400.0

def read_fits_as_2d(path: str, expect_shape: Optional[Tuple[int, int]] = (512, 512)) -> Tuple[np.ndarray, fits.Header]:
    """
    Read FITS (.fits or .fits.gz) and return a 2D float32 image.
    If FITS contains a cube, reduce it to 2D by averaging along the frame axis.
    """
    with fits.open(path, memmap=False) as hdul:
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
            if expect_shape is not None and data.shape[-2:] == expect_shape:
                # (n,ny,nx)
                img = np.mean(data.astype(np.float32, copy=False), axis=0)
            elif expect_shape is not None and data.shape[0:2] == expect_shape:
                # (ny,nx,n)
                img = np.mean(data.astype(np.float32, copy=False), axis=2)
            else:
                ax = int(np.argmin(data.shape))
                img = np.mean(data.astype(np.float32, copy=False), axis=ax)
        else:
            raise RuntimeError(f"Unsupported ndim={data.ndim}")

        if expect_shape is not None and img.shape != expect_shape:
            raise RuntimeError(f"Unexpected image shape {img.shape}, expected {expect_shape}")

        return img.astype(np.float32, copy=False), hdr

def make_output_path_cube3(in_path: str, out_dir: str, suffix: str) -> str:
    """
    Output filename builder (mirrors make_output_path), but intended for 3-layer (science,dark,diff) cubes.
    """
    base = os.path.basename(in_path)
    if base.lower().endswith(".gz"):
        base = base[:-3]
    for ext in (".fits", ".fit", ".fts"):
        if base.lower().endswith(ext):
            base = base[: -len(ext)]
            break
    out_name = f"{base}{suffix}.fits"
    return os.path.join(out_dir, out_name)

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
    apply_to: Optional[List[np.ndarray]] = None,
) -> Tuple[List[np.ndarray], List[Tuple[float, float]], np.ndarray, Optional[List[np.ndarray]]]:
    '''
    Iteratively align frames to a reference that is updated as the coadd.

    Default (subpixel=False):
      - integer cyclic shifts via np.roll (no interpolation artefacts)

    Subpixel (subpixel=True):
      - estimate shifts via skimage phase_cross_correlation (upsampled peak)
      - apply shifts via scipy.ndimage.shift(order=3, mode='wrap') to avoid FFT ringing
      - NOTE: iterative subpixel alignment resamples more than once. Keep n_iters small (1-2).

    NEW:
      - Track *cumulative* shifts (dy,dx) per frame over all iterations.
      - If apply_to is provided (same length as frames), apply the same shifts to it in parallel.
        This is used to keep RAW science frames aligned using shifts measured on DARK-subtracted frames.
    '''
    if not frames:
        raise RuntimeError("No frames to align")

    if apply_to is not None and len(apply_to) != len(frames):
        raise RuntimeError(f"apply_to length {len(apply_to)} != frames length {len(frames)}")

    ref = frames[0].astype(np.float32, copy=False)
    aligned = [f.astype(np.float32, copy=False) for f in frames]

    payload_aligned: Optional[List[np.ndarray]] = None
    if apply_to is not None:
        payload_aligned = [f.astype(np.float32, copy=False) for f in apply_to]

    cum_shifts: List[Tuple[float, float]] = [(0.0, 0.0) for _ in frames]

    n_iters_eff = max(1, int(n_iters))
    if subpixel and n_iters_eff > 2 and verbose:
        print("  NOTE: subpixel mode with >2 iterations may introduce extra interpolation blur; consider --align-iters 1 or 2.")

    for it in range(n_iters_eff):
        if verbose:
            mode = "subpixel" if subpixel else "integer"
            print(f"  ALIGN iter {it+1}/{n_iters_eff} ({mode}): computing shifts to current reference/coadd")

        new_aligned: List[np.ndarray] = []
        new_payload: Optional[List[np.ndarray]] = [] if payload_aligned is not None else None

        for i, fr in enumerate(aligned):
            if subpixel:
                dy, dx, err = phase_correlation_shift_subpixel(ref, fr, upsample_factor=subpix_upsample)
                fr2 = apply_shift_cyclic(fr, dy=dy, dx=dx, subpixel=True, order=subpix_order)
                if payload_aligned is not None:
                    pr2 = apply_shift_cyclic(payload_aligned[i], dy=dy, dx=dx, subpixel=True, order=subpix_order)
                    new_payload.append(pr2)  # type: ignore[arg-type]
                if verbose and (i == 0 or i % 10 == 0):
                    print(f"    frame {i:03d}: shift dy={dy:+.3f} dx={dx:+.3f}  err={err:.4g}")
            else:
                dy_i, dx_i, peak = phase_correlation_shift_int(ref, fr)
                dy = float(dy_i)
                dx = float(dx_i)
                fr2 = apply_shift_cyclic(fr, dy=dy, dx=dx, subpixel=False, order=0)
                if payload_aligned is not None:
                    pr2 = apply_shift_cyclic(payload_aligned[i], dy=dy, dx=dx, subpixel=False, order=0)
                    new_payload.append(pr2)  # type: ignore[arg-type]
                if verbose and (i == 0 or i % 10 == 0):
                    print(f"    frame {i:03d}: shift dy={int(dy):+d} dx={int(dx):+d}  peak={peak:.4f}")

            cdy, cdx = cum_shifts[i]
            cum_shifts[i] = (cdy + float(dy), cdx + float(dx))

            new_aligned.append(fr2)

        aligned = new_aligned
        if payload_aligned is not None and new_payload is not None:
            payload_aligned = list(new_payload)

        ref = np.mean(np.stack(aligned, axis=0), axis=0).astype(np.float32, copy=False)

    coadd = ref
    return aligned, cum_shifts, coadd, payload_aligned


# ---------------------------
# DARK application helpers
# ---------------------------

def make_effective_dark_average(
    dark_comp: np.ndarray,
    total_shifts: List[Tuple[float, float]],
    subpixel: bool,
    subpix_order: int,
) -> np.ndarray:
    '''
    Build the effective DARK in the final aligned/centred coordinate system.

    We subtract DARK before alignment/centring, then shift the DARK-subtracted frames.
    For provenance outputs we want:
      Layer0 = mean of RAW science frames after all shifts
      Layer1 = mean of DARK frames after the same per-frame total shifts
      Layer2 = Layer0 - Layer1 (equals mean of DARK-subtracted frames)
    '''
    if dark_comp.ndim != 2:
        raise RuntimeError(f"dark_comp must be 2D; got {dark_comp.shape}")
    if len(total_shifts) == 0:
        raise RuntimeError("total_shifts is empty")

    acc = np.zeros_like(dark_comp, dtype=np.float32)
    for (dy, dx) in total_shifts:
        dsh = apply_shift_cyclic(dark_comp, dy=dy, dx=dx, subpixel=subpixel, order=int(subpix_order))
        acc += dsh.astype(np.float32, copy=False)
    return (acc / float(len(total_shifts))).astype(np.float32, copy=False)

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


def write_science_dark_diff_cube(
    out_fits: str,
    science2d: np.ndarray,
    dark2d: np.ndarray,
    hdr0: fits.Header,
    discrad: float,
    n_ok: int,
    verbose: bool,
    align_mode: str,
    center_mode: str,
    subpix_upsample: int,
    subpix_order: int,
    sci_jd: Optional[float],
    dark_before: Optional[JDFile],
    dark_after: Optional[JDFile],
) -> None:
    """
    Write a 3-layer cube with axes (layer, ny, nx):
      layer 0: science (averaged, centred)
      layer 1: composite dark = 0.5*(before + after)
      layer 2: difference = science - composite_dark
    """
    if science2d.ndim != 2 or dark2d.ndim != 2:
        raise RuntimeError(f"science2d and dark2d must be 2D; got {science2d.shape} and {dark2d.shape}")
    if science2d.shape != dark2d.shape:
        raise RuntimeError(f"science2d shape {science2d.shape} != dark2d shape {dark2d.shape}")

    diff2d = science2d.astype(np.float32, copy=False) - dark2d.astype(np.float32, copy=False)
    cube3 = np.stack(
        [
            science2d.astype(np.float32, copy=False),
            dark2d.astype(np.float32, copy=False),
            diff2d.astype(np.float32, copy=False),
        ],
        axis=0,
    )  # (3,ny,nx)

    hdr = hdr0.copy()
    hdr["NOK"] = (int(n_ok), "Number of acceptable frames averaged")
    hdr["DISCRAD"] = (float(discrad), "Disc radius [px] from coadd fit")

    hdr["LAYER0"] = ("SCIENCE", "Layer 0 content")
    hdr["LAYER1"] = ("DARKCOMP", "Layer 1 content (0.5*(before+after))")
    hdr["LAYER2"] = ("SCI_MINUS_DARK", "Layer 2 content")

    if sci_jd is not None:
        hdr["SCJD"] = (float(sci_jd), "Science JD from filename")

    if dark_before is not None:
        hdr["DBPATH"] = (os.path.basename(dark_before.path)[:68], "Dark before filename (truncated)")
        hdr["DBJD"] = (float(dark_before.jd), "Dark before JD")
        if sci_jd is not None:
            hdr["DTB_S"] = (float(days_to_seconds(dark_before.jd - sci_jd)), "DBJD - SCJD [seconds] (negative)")
    if dark_after is not None:
        hdr["DAFTER"] = (os.path.basename(dark_after.path)[:68], "Dark after filename (truncated)")
        hdr["DAJD"] = (float(dark_after.jd), "Dark after JD")
        if sci_jd is not None:
            hdr["DTA_S"] = (float(days_to_seconds(dark_after.jd - sci_jd)), "DAJD - SCJD [seconds] (positive)")

    now = datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")
    hdr.add_history(f"Science/Dark/Diff cube written {now}")
    hdr.add_history("Layer0: science mean of centred frames")
    hdr.add_history("Layer1: composite dark = 0.5*(dark_before + dark_after)")
    hdr.add_history("Layer2: science - composite_dark")
    hdr.add_history(f"Alignment mode: {align_mode}")
    hdr.add_history(f"Centring mode:  {center_mode}")

    if "subpixel" in align_mode or "subpixel" in center_mode:
        hdr.add_history(
            f"Subpixel: upsample_factor={int(subpix_upsample)} "
            f"spline_order={int(subpix_order)} mode=wrap"
        )
    else:
        hdr.add_history("Shift is integer cyclic (np.roll)")

    os.makedirs(os.path.dirname(out_fits) or ".", exist_ok=True)
    fits.PrimaryHDU(data=cube3.astype(np.float32, copy=False), header=hdr).writeto(out_fits, overwrite=True)

    print(f"  Wrote science/dark/diff cube: {out_fits}")
    print(f"    shape={cube3.shape} dtype=float32 NOK={n_ok} DISCRAD={discrad:.3f}")
    if verbose:
        print("    NOTE: cube stored as (layer,ny,nx) so FITS NAXIS3=3 layers.")

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

    # DARK bracketing / composite
    ap.add_argument("--dark-list", default=None,
                    help="Optional: path to list of DARK frames for bracketing by JD (one path per line).")
    ap.add_argument("--dark-expect-ny", type=int, default=512)
    ap.add_argument("--dark-expect-nx", type=int, default=512)
    ap.add_argument("--cube3-suffix", default="_SCI_DARK_DIFF",
                    help="Suffix for 3-layer output cube when --dark-list is provided.")
    ap.add_argument("--keep-avg2d", action="store_true",
                    help="Also write the old 2D averaged science image (in addition to the 3-layer cube).")
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

    # Optional: load DARK list and build JD index once
    dark_jds_sorted: Optional[List[float]] = None
    dark_items_sorted: Optional[List[JDFile]] = None
    dark_bad: List[str] = []

    if args.dark_list is not None:
        dark_paths = read_file_list(args.dark_list)
        if not dark_paths:
            print(f"ERROR: --dark-list provided but list is empty: {args.dark_list}", file=sys.stderr)
            return 2
        dark_jds_sorted, dark_items_sorted, dark_bad = build_sorted_jd_files(dark_paths, label="DARK")
        print(f"Loaded DARK list for bracketing: {len(dark_items_sorted)} (bad JD parse: {len(dark_bad)})")
        if dark_bad:
            print("WARNING: Some DARK paths had no parsable JD (first 5):")
            for bp in dark_bad[:5]:
                print("  ", bp)
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

        # If DARK list is provided, prepare composite DARK for this science file (used for per-frame subtraction BEFORE alignment)
        dark_comp_file: Optional[np.ndarray] = None
        dark_before_file: Optional[JDFile] = None
        dark_after_file: Optional[JDFile] = None
        sci_jd_file: Optional[float] = None

        if args.dark_list is not None:
            sci_jd_file = parse_jd_from_path(p)
            if sci_jd_file is None:
                print("  DARK: cannot parse JD from science filename; skipping file.")
                continue
            if dark_jds_sorted is None or dark_items_sorted is None:
                print("  DARK: internal error (dark index missing); skipping file.")
                continue

            dark_before_file, dark_after_file = find_bracketing(dark_jds_sorted, dark_items_sorted, sci_jd_file)
            if dark_before_file is None or dark_after_file is None:
                print("  DARK: NO_BRACKET (missing before or after DARK); skipping file.")
                continue

            dtb_s = days_to_seconds(dark_before_file.jd - sci_jd_file)
            dta_s = days_to_seconds(dark_after_file.jd - sci_jd_file)
            print("  DARK bracket (for subtraction BEFORE alignment):")
            print(f"    before: {dark_before_file.path}  dt={dtb_s:+.1f} s")
            print(f"    after : {dark_after_file.path}  dt={dta_s:+.1f} s")

            try:
                dimg_b, _ = read_fits_as_2d(dark_before_file.path, expect_shape=(args.dark_expect_ny, args.dark_expect_nx))
                dimg_a, _ = read_fits_as_2d(dark_after_file.path, expect_shape=(args.dark_expect_ny, args.dark_expect_nx))
                dark_comp_file = (0.5 * (dimg_b + dimg_a)).astype(np.float32, copy=False)
            except Exception as e:
                print(f"  DARK: failed to read/make composite for file: {e}")
                continue
        ok_frames_raw: List[np.ndarray] = []
        ok_frames_darksub: List[np.ndarray] = []
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
                    fr_raw = frame2d.astype(np.float32, copy=False)

                    # Subtract composite DARK *before* alignment/centring (if available).
                    if dark_comp_file is not None:
                        fr_ds = (fr_raw - dark_comp_file).astype(np.float32, copy=False)
                        ok_frames_raw.append(fr_raw)
                        ok_frames_darksub.append(fr_ds)
                    else:
                        ok_frames_raw.append(fr_raw)
                        ok_frames_darksub.append(fr_raw)

                    n_ok += 1

            if hdr0 is None:
                print("  BAD: no header/data found.")
                continue

            print(f"  Exposure selection: inspected={n_in_file} OK={n_ok}")

            if n_ok == 0:
                print("  No OK frames; skipping.")
                continue

            # 1) Align frames (integer default, optional subpixel)
            aligned_ds, cum_shifts, coadd, aligned_raw = align_stack_iterative(
                ok_frames_darksub,
                n_iters=args.align_iters,
                verbose=args.verbose,
                subpixel=bool(args.subpixel),
                subpix_upsample=int(args.subpix_upsamp),
                subpix_order=int(args.subpix_order),
                apply_to=ok_frames_raw,
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
            # Total shifts = per-frame alignment (cum_shifts) + this final centring shift.
            total_shifts: List[Tuple[float, float]] = []

            if aligned_raw is None:
                raise RuntimeError("Internal error: aligned_raw is None (should not happen).")

            if not do_center_subpix:
                ix = int(np.rint(dx))
                iy = int(np.rint(dy))
                print(f"  Centring shift from coadd: dx={dx:.3f}->{ix}  dy={dy:.3f}->{iy}  (integer cyclic)")

                centred_ds = [apply_shift_cyclic(fr, dy=iy, dx=ix, subpixel=False, order=0) for fr in aligned_ds]
                centred_raw = [apply_shift_cyclic(fr, dy=iy, dx=ix, subpixel=False, order=0) for fr in aligned_raw]

                for (cdy, cdx) in cum_shifts:
                    total_shifts.append((cdy + float(iy), cdx + float(ix)))

                center_mode = "integer cyclic (np.roll)"
            else:
                print(f"  Centring shift from coadd: dx={dx:.3f}  dy={dy:.3f}  (subpixel, wrap, order={int(args.subpix_order)})")

                centred_ds = [apply_shift_cyclic(fr, dy=dy, dx=dx, subpixel=True, order=int(args.subpix_order)) for fr in aligned_ds]
                centred_raw = [apply_shift_cyclic(fr, dy=dy, dx=dx, subpixel=True, order=int(args.subpix_order)) for fr in aligned_raw]

                for (cdy, cdx) in cum_shifts:
                    total_shifts.append((cdy + float(dy), cdx + float(dx)))

                center_mode = f"subpixel (ndimage.shift wrap order={int(args.subpix_order)})"
            # 4) Stack and average centred frames
            cube_ds = np.stack(centred_ds, axis=0)   # (n,ny,nx)  DARK-subtracted
            avg_ds = np.mean(cube_ds, axis=0)        # (ny,nx)    DARK-corrected science

            cube_raw = np.stack(centred_raw, axis=0) # (n,ny,nx)  RAW science
            avg_raw = np.mean(cube_raw, axis=0)      # (ny,nx)    RAW science (centred)

            avg_dark_eff: Optional[np.ndarray] = None
            if dark_comp_file is not None:
                avg_dark_eff = make_effective_dark_average(
                    dark_comp_file,
                    total_shifts=total_shifts,
                    subpixel=bool(do_center_subpix),
                    subpix_order=int(args.subpix_order),
                )

            out_path = make_output_path(p, args.out_dir, args.suffix + "_AVG")

            align_mode = (
                "subpixel (skimage phase_cross_correlation)"
                if args.subpixel
                else "integer cyclic phase correlation"
            )

            # Optional: also write the old 2D averaged science image
            if args.keep_avg2d or (args.dark_list is None):
                write_averaged_image(
                    out_path,
                    avg_ds,
                    hdr0,
                    discrad=r,
                    n_ok=len(centred),
                    verbose=args.verbose,
                    align_mode=align_mode,
                    center_mode=center_mode,
                    subpix_upsample=int(args.subpix_upsamp),
                    subpix_order=int(args.subpix_order),
                )
            # If a DARK list is provided, write 3-layer cube:
            #   Layer0 = RAW science average (centred/aligned)
            #   Layer1 = Effective DARK average in the same centred/aligned coordinate system
            #   Layer2 = Layer0 - Layer1  (DARK-corrected science average)
            if args.dark_list is not None:
                if sci_jd_file is None:
                    sci_jd_file = parse_jd_from_path(p)

                if dark_comp_file is None or avg_dark_eff is None:
                    print("  DARK: composite/avg_dark_eff missing; skipping cube3.")
                else:
                    out_cube3 = make_output_path_cube3(p, args.out_dir, args.cube3_suffix)
                    write_science_dark_diff_cube(
                        out_cube3,
                        science2d=avg_raw,
                        dark2d=avg_dark_eff,
                        hdr0=hdr0,
                        discrad=r,
                        n_ok=len(centred_ds),
                        verbose=args.verbose,
                        align_mode=align_mode,
                        center_mode=center_mode,
                        subpix_upsample=int(args.subpix_upsamp),
                        subpix_order=int(args.subpix_order),
                        sci_jd=sci_jd_file,
                        dark_before=dark_before_file,
                        dark_after=dark_after_file,
                    )

        except Exception as e:
            print(f"  BAD: exception: {e}", file=sys.stderr)
            continue

    print("\nDONE.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
