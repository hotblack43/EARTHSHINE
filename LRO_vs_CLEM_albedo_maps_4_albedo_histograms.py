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
    clem = np.loadtxt('./Eshine/data_eshine/HIRES_750_3ppd.alb')  # whitespace-delimited
    print("CLEM shape:", clem.shape)
    clem = clem.reshape(540, 1080)
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

# --- Compare and plot histograms of ratios ---
def plot_lro_clem_ratios():
    lro = get_lro_albedo()
    clem = get_clem_albedo()
    lon_lro, lat_lro = get_coord_grids(lro.shape[2], lro.shape[1])
    lon_clem, lat_clem = get_coord_grids(clem.shape[1], clem.shape[0])

    lons = np.linspace(-80, 80, 200)
    lats = np.linspace(-80, 80, 200)

    for band in range(lro.shape[0]):
        ratios = []
        for lat in lats:
            for lon in lons:
                lon_mod = lon % 360  # wrap longitude for global grid
                lro_val = bilinear_interpolate(lro[band], lon_lro, lat_lro, lon_mod, lat)
                clem_val = bilinear_interpolate(clem, lon_clem, lat_clem, lon_mod, lat)
                if clem_val > 0:
                    ratios.append(lro_val / clem_val)

        plt.figure()
        plt.hist(ratios, bins=100, range=(0.5, 1.5), color='gray', edgecolor='black')
        plt.title(f'LRO Band {band} / Clementine Histogram')
        plt.xlabel('Ratio (LRO / CLEM)')
        plt.ylabel('Frequency')
        plt.grid(True)
    plt.show()

# --- Run diagnostics ---
if __name__ == '__main__':
    plot_lro_clem_ratios()

