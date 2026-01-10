import math
import numpy as np
import matplotlib.pyplot as plt
import tifffile
from scipy.interpolate import RegularGridInterpolator

# --- Load LRO Albedo Data ---
def get_lro_albedo():
    im = tifffile.imread('Eshine/1x1_70NS_7b_wbhs_albflt_grid_geirist_tcorrect_w.tif')
    print("Raw LRO shape:", im.shape)  # e.g., (7, 140, 360)
    return im

# --- Load Clementine Albedo ---
def get_clem_albedo():
#   clem = np.fromfile('./Eshine/data_eshine/HIRES_750_3ppd.alb', dtype=np.float64)
#    clem = np.loadtxt('./Eshine/data_eshine/HIRES_750_3ppd.alb', delimiter=',')
    clem = np.loadtxt('./Eshine/data_eshine/HIRES_750_3ppd.alb')  # defaults to any whitespace
    print("CLEM shape:", clem.shape)
    ny = 285
    nx = 358
    #clem = clem.reshape(ny, nx)
    clem = clem.reshape(540, 1080)
    print("Raw CLEM shape:", clem.shape)
    return clem

# --- Coordinate Grids ---
def get_coord_grids(lon_len, lat_len):
    lon = np.linspace(0, 360, lon_len, endpoint=False)
    lat = np.linspace(-90, 90, lat_len)
    return lon, lat

# --- Interpolation Function ---
def bilinear_interpolate(image, lon_arr, lat_arr, lon, lat):
    interp = RegularGridInterpolator((lat_arr, lon_arr), image, bounds_error=False, fill_value=np.nan)
    return interp([[lat, lon]])[0]

# --- Query both datasets at (lon, lat) ---
def query_albedos(lon, lat, band=0):
    lro = get_lro_albedo()
    clem = get_clem_albedo()
    lon_lro, lat_lro = get_coord_grids(lro.shape[2], lro.shape[1])
    lon_clem, lat_clem = get_coord_grids(clem.shape[1], clem.shape[0])

    lro_val = bilinear_interpolate(lro[band], lon_lro, lat_lro, lon, lat)
    clem_val = bilinear_interpolate(clem, lon_clem, lat_clem, lon, lat)

    return lro_val, clem_val

# --- Visualize LRO Bands ---
def show_lro_bands(lro_cube):
    n_bands = lro_cube.shape[0]
    fig, axes = plt.subplots(1, n_bands, figsize=(3*n_bands, 4))
    for i in range(n_bands):
        ax = axes[i]
        ax.imshow(lro_cube[i], cmap='gray', origin='lower')
        ax.set_title(f'LRO Band {i}')
        ax.axis('off')
    plt.tight_layout()
    plt.show()

# --- Run diagnostics ---
if __name__ == '__main__':
    lon_q, lat_q = 10.0, 10.0
    band_q = 0
    lro_val, clem_val = query_albedos(lon_q, lat_q, band=band_q)
    print(f"LRO band {band_q} at ({lon_q}, {lat_q}): {lro_val}")
    print(f"Clementine at ({lon_q}, {lat_q}): {clem_val}")

    lro_data = get_lro_albedo()
    show_lro_bands(lro_data)

