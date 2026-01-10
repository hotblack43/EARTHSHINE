import math
import numpy as np
import matplotlib.pyplot as plt
import tifffile
from scipy.interpolate import RegularGridInterpolator

# --- Load LRO Albedo Data ---
def get_lro_albedo():
    im = tifffile.imread('Eshine/1x1_70NS_7b_wbhs_albflt_grid_geirist_tcorrect_w.tif')
    print("Raw LRO shape:", im.shape)  # e.g., (7, 140, 360)
    im = im[:, ::-1, :]  # Flip both latitude and longitude
    lon = np.linspace(0, 360, im.shape[2], endpoint=False)
#   lat = np.linspace(-90, 90, im.shape[1])[::-1]  # Flip to match image
    lat = np.linspace(-70, 70, im.shape[1])
    return im, lon, lat

# --- Load Clementine Albedo ---
def get_clem_albedo():
    clem = np.loadtxt('./Eshine/data_eshine/HIRES_750_3ppd.alb')  # whitespace-delimited
    print("CLEM shape:", clem.shape)
    clem = clem.reshape(540, 1080)
    lon = np.linspace(0, 360, 1080, endpoint=False)
    lat = np.linspace(-90, 90, 540)
    return clem, lon, lat

# --- Interpolation Function ---
def bilinear_interpolate(image, lon_arr, lat_arr, lon, lat):
    interp = RegularGridInterpolator((lat_arr, lon_arr), image, bounds_error=False, fill_value=np.nan)
    return interp([[lat, lon]])[0]

# --- Side-by-side visual inspection ---
def show_clem_vs_lro_maps():
    lro, _, _ = get_lro_albedo()
    clem, _, _ = get_clem_albedo()

    for band in range(lro.shape[0]):
        fig, axs = plt.subplots(1, 2, figsize=(12, 5))

        axs[0].imshow(clem, cmap='gray', origin='lower')
        axs[0].set_title('Clementine Map')
        axs[0].axis('off')

        axs[1].imshow(lro[band], cmap='gray', origin='lower')
        axs[1].set_title(f'LRO Band {band}')
        axs[1].axis('off')

        plt.suptitle(f'Clementine vs. LRO Band {band}')
        plt.tight_layout()
        plt.show()
        fig.savefig(f'FIGURES/map_band_{band}.png')

# --- Compare and plot histograms of ratios ---
def plot_lro_clem_ratios():
    lro, lon_lro, lat_lro = get_lro_albedo()
    clem, lon_clem, lat_clem = get_clem_albedo()

    lons = np.linspace(-80, 80, 200)
    lats = np.linspace(-60, 60, 200)

    fig, axs = plt.subplots(3, 3, figsize=(12, 10))
    axs = axs.ravel()

    for band in range(lro.shape[0]):
        ratios = []
        for lat in lats:
            for lon in lons:
                lon_mod = lon % 360  # wrap longitude for global grid
                lro_val = bilinear_interpolate(lro[band], lon_lro, lat_lro, lon_mod, lat)
                clem_val = bilinear_interpolate(clem, lon_clem, lat_clem, lon_mod, lat)
                if clem_val > 0:
                    ratios.append(lro_val / clem_val)

        axs[band].hist(ratios, bins=100, range=(0.5, 6.5), color='gray', edgecolor='black')
        mean = np.nanmean(ratios)
        std = np.nanstd(ratios)
        axs[band].set_title(f'LRO Band {band}')
        axs[band].set_xlabel('Ratio (LRO / CLEM)')
        axs[band].set_ylabel('Frequency')
        axs[band].grid(True)
        print('Band ',band,' ',mean,'+/-',std)

    for i in range(lro.shape[0], len(axs)):
        axs[i].axis('off')

    plt.suptitle('Histograms of LRO/Clementine Ratios by Band')
    plt.tight_layout()
    plt.show()
    fig.savefig('FIGURES/histogram_ratios.png')

# --- Line comparison at lat=10 deg ---
def compare_transect_lat10():
    lro, lon_lro, lat_lro = get_lro_albedo()
    clem, lon_clem, lat_clem = get_clem_albedo()

    lat = 10
    lons = np.linspace(0, 360, 1000)

    fig, ax = plt.subplots(figsize=(12, 5))
    for band in range(lro.shape[0]):
        lro_vals = [bilinear_interpolate(lro[band], lon_lro, lat_lro, lon, lat) for lon in lons]
        ax.plot(lons, lro_vals, label=f'LRO Band {band}')

    clem_vals = [bilinear_interpolate(clem, lon_clem, lat_clem, lon, lat) for lon in lons]
    ax.plot(lons, clem_vals, label='Clementine', color='black', linewidth=2, linestyle='--')

    ax.set_title('Albedo Transect at Latitude = 10°')
    ax.set_xlabel('Longitude [deg]')
    ax.set_ylabel('Albedo')
    ax.grid(True)
    ax.legend()
    plt.tight_layout()
    plt.show()
    fig.savefig('FIGURES/transect_lat10.png')

# --- Run diagnostics ---
if __name__ == '__main__':
    show_clem_vs_lro_maps()
    plot_lro_clem_ratios()
    compare_transect_lat10()
