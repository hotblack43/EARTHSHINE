import re
import numpy as np
import scipy.optimize as opt
import scipy.interpolate as interp
from astropy.io import fits
from astropy.time import Time
from astroquery.jplhorizons import Horizons
import os
import glob
import multiprocessing

# --- Step 1: Extract Julian Date from Filename ---
def get_julian_date_from_filename(filename):
    match = re.search(r"_JD(\d+\.\d+)", filename)
    if match:
        return float(match.group(1))  

    match = re.search(r"245\d+\.\d+", filename)
    if match:
        return float(match.group())

    raise ValueError(f"Julian Date (JD) not found in filename: {filename}")

# --- Step 2: Get Phase Angle from JD ---
def get_phase_angle(julian_date):
    moon_id = '301'  # NASA HORIZONS ID for the Moon
    obs_id = '500'   # Earth-centered observer (geocentric)
    eph = Horizons(id=moon_id, location=obs_id, epochs=julian_date).ephemerides()
    return np.radians(float(eph['alpha']))  # Convert degrees to radians

# --- Step 3: Load Data from FITS Cube (Optimized) ---
def load_fits_data(fits_cube_path):
    with fits.open(fits_cube_path, memmap=True) as hdu:  # Enable memmap for large files
        data_cube = hdu[0].data
        header = hdu[0].header  

        julian_date = get_julian_date_from_filename(os.path.basename(fits_cube_path))
        phase_angle = get_phase_angle(julian_date)

        radiance_map = data_cube[0]  # Layer 1: Radiance
        incidence_map = data_cube[3]  # Layer 4: Incidence Angle (already in radians)
        emergence_map = data_cube[5]  # Layer 6: Emergence Angle (already in radians)
        azimuth_map = np.radians(data_cube[7])  # Layer 8: Azimuth (converted to radians)

        valid_mask = (radiance_map > 0) & (incidence_map > 0) & (emergence_map > 0) & (~np.isnan(azimuth_map))
    
    return valid_mask, radiance_map, incidence_map, emergence_map, azimuth_map, phase_angle, julian_date

# --- Step 4: Optimize Albedo Calculation Using NumPy ---
def update_albedo_vectorized(incidence, emergence, phase_angle, radiance, brdf_func):
    """
    Vectorized update for albedo computation.
    """
    def cost_function(albedo):
        return np.abs(albedo * brdf_func((incidence, emergence, phase_angle)) - radiance)
    
    optimized_albedo = opt.minimize_scalar(cost_function, bounds=(0.01, 1.0), method='bounded').x
    return optimized_albedo

# --- Step 5: Optimize BRDF Calculation ---
def update_brdf(all_valid_angles, all_reflectance_values):
    """
    Updates BRDF function using data from all images.
    Uses NearestNDInterpolator if LinearNDInterpolator fails.
    """
    if len(all_valid_angles) == 0 or len(all_reflectance_values) == 0:
        print("⚠️ Warning: No valid BRDF data to update. Returning default function.")
        return lambda x: 1.0  # Default function returning constant reflectance

    angles = np.vstack(all_valid_angles)
    reflectance_values = np.concatenate(all_reflectance_values)

    jitter = 1e-6 * np.random.randn(*angles.shape)  # Avoid precision issues
    angles += jitter  

    try:
        brdf_func = interp.LinearNDInterpolator(angles, reflectance_values)
    except Exception:
        brdf_func = interp.NearestNDInterpolator(angles, reflectance_values)

    return brdf_func

# --- Step 6: Process Multiple FITS Files in Parallel ---
def process_fits_file(fits_cube_path):
    valid_mask, radiance_map, incidence_map, emergence_map, azimuth_map, phase_angle, julian_date = load_fits_data(fits_cube_path)

    # Only keep valid pixels
    valid_pixels = valid_mask.flatten()
    angles = np.vstack([
        incidence_map.flatten()[valid_pixels], 
        emergence_map.flatten()[valid_pixels], 
        np.full(np.sum(valid_pixels), phase_angle)
    ]).T
    reflectance_values = radiance_map.flatten()[valid_pixels]

    return angles, reflectance_values

def iterative_solve(fits_directory, output_fits_path, max_iterations=10):
    fits_files = sorted(glob.glob(os.path.join(fits_directory, "*.fits")))

    if not fits_files:
        raise ValueError("No FITS files found in directory.")

    all_valid_angles = []
    all_reflectance_values = []

    # Use multiprocessing for faster FITS file processing
    with multiprocessing.Pool(processes=os.cpu_count()) as pool:
        results = pool.map(process_fits_file, fits_files)
    
    for angles, reflectance_values in results:
        all_valid_angles.append(angles)
        all_reflectance_values.append(reflectance_values)

    # Compute BRDF function after all images are processed
    brdf_func = update_brdf(all_valid_angles, all_reflectance_values)

    print(f"✅ Final BRDF function computed across {len(fits_files)} images")

    # Save BRDF model for later use
    np.save("brdf_model.npy", brdf_func)

    print(f"✅ BRDF model saved to 'brdf_model.npy'")

# --- Run Pipeline ---
fits_directory = "/home/pth/WORKSHOP/EARTHSHINE_CODE/OUTPUT/CUBES/"
output_fits_path = "final_albedo_map.fits"

iterative_solve(fits_directory, output_fits_path)

