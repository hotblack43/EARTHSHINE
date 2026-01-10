import numpy as np
import tifffile

# --- Load LRO Albedo Data ---
def get_lro_albedo():
    # Load TIFF image: expected shape = (7 bands, height, width)
    im = tifffile.imread('Eshine/1x1_70NS_7b_wbhs_albflt_grid_geirist_tcorrect_w.tif')

    # Rebin to shape (7, 1080, 420)
    im = im.reshape((7, 1080, 140 * 3))

    # Pad with NaN rows above and below (60 rows total to reach 540 height)
    blanks = np.full((7, 1080, (540 - 420) // 2), np.nan)
    im = np.concatenate((blanks, im, blanks), axis=2)

    return im

# --- Load Clementine Albedo ---
def get_clem_albedo():
    clem = np.fromfile('./Eshine/data_eshine/HIRES_750_3ppd.alb', dtype=np.float32).reshape(540, 1080)
    return clem

# --- Coordinate Grids ---
def get_coord_grids():
    lon = np.arange(1080) / 3.0  # 360 deg / 3ppd
    lat = np.arange(540) / 3.0 - 90.0
    lat = lat[::-1]  # reverse to match image grid
    return lon, lat

# --- Interpolation Function ---
def bilinear_interpolate(image, lon_arr, lat_arr, lon, lat):
    from scipy.interpolate import RegularGridInterpolator

    interp = RegularGridInterpolator((lat_arr, lon_arr), image, bounds_error=False, fill_value=np.nan)
    return interp([[lat, lon]])[0]

# --- Query both datasets at (lon, lat) ---
def query_albedos(lon, lat):
    lro = get_lro_albedo()
    clem = get_clem_albedo()
    lon_grid, lat_grid = get_coord_grids()

    lro_vals = [bilinear_interpolate(lro[band], lon_grid, lat_grid, lon, lat) for band in range(7)]
    clem_val = bilinear_interpolate(clem, lon_grid, lat_grid, lon, lat)

    return np.array(lro_vals), clem_val

# --- Example Query ---
if __name__ == '__main__':
    lon_q, lat_q = 10.0, 10.0
    lro_bands, clem_val = query_albedos(lon_q, lat_q)
    print(f"LRO bands at ({lon_q}, {lat_q}): {lro_bands}")
    print(f"Clementine value at ({lon_q}, {lat_q}): {clem_val}")

