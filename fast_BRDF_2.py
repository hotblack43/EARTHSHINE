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

#
# calculates albedo map from lunar images
#
# may need more images?
#
# Seems to calculate the BDRF first and then the albedomap which is strange
#


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
    moon_id = '301'
    obs_id = '500'
    eph = Horizons(id=moon_id, location=obs_id, epochs=julian_date).ephemerides()
    return np.radians(float(eph['alpha']))

# --- Step 3: Load Data from FITS Cube (Optimized) ---
def load_fits_data(fits_cube_path):
    with fits.open(fits_cube_path, memmap=True) as hdu:
        data_cube = hdu[0].data
        header = hdu[0].header  

        julian_date = get_julian_date_from_filename(os.path.basename(fits_cube_path))
        phase_angle = get_phase_angle(julian_date)

        radiance_map = data_cube[0]
        incidence_map = data_cube[3]
        emergence_map = data_cube[5]
        azimuth_map = np.radians(data_cube[7])

        valid_mask = (radiance_map > 0) & (incidence_map > 0) & (emergence_map > 0) & (~np.isnan(azimuth_map))
    
    return valid_mask, radiance_map, incidence_map, emergence_map, azimuth_map, phase_angle, julian_date

# --- Step 4: Optimize Albedo Calculation Using NumPy ---
def compute_albedo_map(incidence_map, emergence_map, phase_angle, radiance_map, brdf_func, valid_mask):
    """
    Vectorized calculation of albedo.
    """
    def cost_function(albedo, inc, em, ph, rad):
        return np.abs(albedo * brdf_func((inc, em, ph)) - rad)
    
    optimized_albedo = np.zeros_like(radiance_map)
    
    indices = np.where(valid_mask)
    for i, j in zip(indices[0], indices[1]):
        result = opt.minimize_scalar(
            cost_function, 
            bounds=(0.01, 1.0), 
            method='bounded',
            args=(incidence_map[i, j], emergence_map[i, j], phase_angle, radiance_map[i, j])
        )
        optimized_albedo[i, j] = result.x
    
    return optimized_albedo

# --- Step 5: Optimize BRDF Calculation ---
def update_brdf(all_valid_angles, all_reflectance_values):
    if len(all_valid_angles) == 0 or len(all_reflectance_values) == 0:
        print("⚠️ Warning: No valid BRDF data to update. Returning default function.")
        return lambda x: 1.0  

    angles = np.vstack(all_valid_angles)
    reflectance_values = np.concatenate(all_reflectance_values)

    jitter = 1e-6 * np.random.randn(*angles.shape)
    angles += jitter  

    try:
        brdf_func = interp.LinearNDInterpolator(angles, reflectance_values)
    except Exception:
        brdf_func = interp.NearestNDInterpolator(angles, reflectance_values)

    return brdf_func

# --- Step 6: Process Multiple FITS Files in Parallel ---
def process_fits_file(fits_cube_path):
    valid_mask, radiance_map, incidence_map, emergence_map, azimuth_map, phase_angle, julian_date = load_fits_data(fits_cube_path)

    valid_pixels = valid_mask.flatten()
    angles = np.vstack([
        incidence_map.flatten()[valid_pixels], 
        emergence_map.flatten()[valid_pixels], 
        np.full(np.sum(valid_pixels), phase_angle)
    ]).T
    reflectance_values = radiance_map.flatten()[valid_pixels]

    return angles, reflectance_values, fits_cube_path, valid_mask, radiance_map, incidence_map, emergence_map, phase_angle

def iterative_solve(fits_directory, output_fits_path, max_iterations=10):
    fits_files = sorted(glob.glob(os.path.join(fits_directory, "*.fits")))

    if not fits_files:
        raise ValueError("No FITS files found in directory.")

    all_valid_angles = []
    all_reflectance_values = []

    processed_data = []
    
    # Use multiprocessing for faster FITS file processing
    with multiprocessing.Pool(processes=os.cpu_count()) as pool:
        results = pool.map(process_fits_file, fits_files)

    for angles, reflectance_values, fits_cube_path, valid_mask, radiance_map, incidence_map, emergence_map, phase_angle in results:
        all_valid_angles.append(angles)
        all_reflectance_values.append(reflectance_values)
        processed_data.append((fits_cube_path, valid_mask, radiance_map, incidence_map, emergence_map, phase_angle))

    # Compute BRDF function after all images are processed
    brdf_func = update_brdf(all_valid_angles, all_reflectance_values)
    np.save("brdf_model.npy", brdf_func)
    print(f"✅ Final BRDF function computed across {len(fits_files)} images")

    # Compute final albedo map
    final_albedo_map = None
    for fits_cube_path, valid_mask, radiance_map, incidence_map, emergence_map, phase_angle in processed_data:
        albedo_map = compute_albedo_map(incidence_map, emergence_map, phase_angle, radiance_map, brdf_func, valid_mask)
        
        if final_albedo_map is None:
            final_albedo_map = albedo_map
        else:
            final_albedo_map += albedo_map

    final_albedo_map /= len(processed_data)  # Average over all images

    # Save updated albedo map as new FITS layer
    with fits.open(fits_files[0], mode='update') as hdu:
        new_cube = np.vstack([hdu[0].data, final_albedo_map[np.newaxis, :, :]])
        header = hdu[0].header
        header.add_comment(f"Layer {new_cube.shape[0]}: Final albedo map computed iteratively across all images.")

        hdu_out = fits.PrimaryHDU(new_cube, header=header)
        hdu_out.writeto(output_fits_path, overwrite=True)

    print(f"✅ Final albedo map saved to: {output_fits_path}")

# --- Run Pipeline ---
fits_directory = "/home/pth/WORKSHOP/EARTHSHINE_CODE/OUTPUT/CUBES/"
output_fits_path = "final_albedo_map.fits"

iterative_solve(fits_directory, output_fits_path)

