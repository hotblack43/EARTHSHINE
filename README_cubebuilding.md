Subject: README.md – Combining Observed and Synthetic FITS Cubes

# Combining Observed and Synthetic FITS Cubes

## Purpose

This workflow combines two independently generated FITS data products into a single multi-layer FITS cube:

* **Observed cubes** built from real lunar observations (aligned and averaged frames)
* **Synthetic cubes** generated separately from a modelling pipeline

The two products are matched by **Julian Date (JD)** and merged for joint analysis.

---

## Inputs

### Observed cubes

* One FITS file per observation
* Filename contains the JD
* Shape: `(N_obs, ny, nx)`
* Header contains full observational metadata

Use code like go_align_observed.sh

### Synthetic cubes

* One FITS file per JD
* Filename example: `MLOcube_2456106.8317655MOON_VE2_AIR_SCI_DARK_DIFF.fits`
* Shape: `(N_syn, ny, nx)`

Observed and synthetic cubes are produced by **separate scripts**.

---

## What `glue_cubes.py` does

For each observed cube:

1. Extracts JD from filename
2. Finds matching synthetic cube
3. Optionally flips one cube left–right
4. Concatenates observed and synthetic layers
5. Writes a combined FITS cube

Output shape:

```
(N_obs + N_syn, ny, nx)
```

All observational metadata are retained.

---

## Layer descriptions

Layer contents are stored as:

```
LAYER01 .. LAYERNN
```

Descriptions can be provided explicitly:

```bash
--layer-desc-file layers.txt
```

(one line per layer, in final order).
Only a **single, clean layer labelling scheme** is written.

---

## Usage

```bash
uv run glue_cubes.py \
  --obs-dir CENTERED \
  --syn-dir OUTPUT/CUBES \
  --out-dir OUTPUT/COMBINED \
  --flip syn \
  --layer-desc-file layers.txt
```

---

## Output

Combined files are written to:

```
OUTPUT/COMBINED/MLOcube_xxxx.xxxxxMOON_yyy_AIR_SCI_DARK_DIFF.fits

```

Each file contains the merged data cube, full metadata, and provenance.

