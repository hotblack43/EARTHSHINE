import re
import numpy as np
import scipy.optimize as opt
import scipy.interpolate as interp
from astropy.io import fits
from astropy.time import Time
from astroquery.jplhorizons import Horizons
import os
import glob

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

# --- Step 3: Load Data from FITS Cube ---
def load_fits_data(fits_cube_path):
    with fits.open(fits_cube_path) as hdu:
        data_cube = hdu[0].data
        header = hdu[0].header  

        julian_date = get_julian_date_from_filename(os.path.basename(fits_cube_path))
        phase_angle = get_phase_angle(julian_date)

        incidence_map = data_cube[0, :, :]
        emission_map = data_cube[1, :, :]
        azimuthal_map = data_cube[2, :, :]
        reflectance_map = data_cube[3, :, :]

    return incidence_map, emission_map, azimuthal_map, reflectance_map, phase_angle, julian_date

# --- Step 4: Initialize BRDF Interpolation ---
def initialize_brdf(angles, reflectance_values):
    return interp.LinearNDInterpolator(angles, reflectance_values)

# --- Step 5: Solve for Albedo ---
def update_albedo(incidence, emission, phase_angle, observed_reflectance, brdf_func):
    def cost_function(albedo):
        modeled_reflectance = albedo * brdf_func([incidence, emission, phase_angle])
        return np.abs(modeled_reflectance - observed_reflectance)
    
    result = opt.minimize_scalar(cost_function, bounds=(0.01, 1.0), method='bounded')
    return result.x

# --- Step 6: Solve for BRDF ---
def update_brdf(incidence_map, emission_map, phase_angle, reflectance_map, albedo_map):
    valid_mask = reflectance_map > 0
    angles = np.vstack([incidence_map[valid_mask], emission_map[valid_mask], np.full_like(incidence_map[valid_mask], phase_angle)]).T
    brdf_values = reflectance_map[valid_mask] / albedo_map[valid_mask]
    return interp.LinearNDInterpolator(angles, brdf_values)

# --- Step 7: Iterative Albedo & BRDF Estimation Over All FITS Cubes ---
def iterative_solve(fits_directory, output_fits_path, max_iterations=10):
    """
    Iteratively estimates albedo map and BRDF function across multiple FITS cubes.
    """
    fits_files = sorted(glob.glob(os.path.join(fits_directory, "*.fits")))

    if not fits_files:
        raise ValueError("No FITS files found in directory.")

    all_albedo_maps = []
    all_phase_angles = []

    for idx, fits_cube_path in enumerate(fits_files):
        print(f"Processing {fits_cube_path} ({idx+1}/{len(fits_files)})")

        incidence_map, emission_map, azimuthal_map, reflectance_map, phase_angle, julian_date = load_fits_data(fits_cube_path)
        all_phase_angles.append(phase_angle)

        if idx == 0:
            albedo_map = np.ones_like(reflectance_map) * 0.1  # Initial guess
            valid_mask = reflectance_map > 0
            angles = np.vstack([incidence_map[valid_mask], emission_map[valid_mask], np.full_like(incidence_map[valid_mask], phase_angle)]).T
            brdf_func = initialize_brdf(angles, reflectance_map[valid_mask] / np.mean(reflectance_map[valid_mask]))

        for iteration in range(max_iterations):
            print(f"Iteration {iteration + 1}")

            # Step 7A: Solve for albedo per pixel
            for i in range(incidence_map.shape[0]):
                for j in range(incidence_map.shape[1]):
                    if reflectance_map[i, j] > 0:  # Avoid sky pixels
                        albedo_map[i, j] = update_albedo(incidence_map[i, j], emission_map[i, j], phase_angle, reflectance_map[i, j], brdf_func)

            # Step 7B: Solve for BRDF given updated albedo map
            brdf_func = update_brdf(incidence_map, emission_map, phase_angle, reflectance_map, albedo_map)

            # Step 7C: Check for convergence
            if np.max(np.abs(albedo_map - albedo_map.mean())) < 0.001:
                break

        all_albedo_maps.append(albedo_map)

    # Compute final albedo map as average across all datasets
    final_albedo_map = np.mean(all_albedo_maps, axis=0)

    # Save updated albedo map as new FITS layer
    with fits.open(fits_files[0], mode='update') as hdu:
        new_cube = np.vstack([hdu[0].data, final_albedo_map[np.newaxis, :, :]])
        header = hdu[0].header
        header.add_comment(f"Layer {new_cube.shape[0]}: Final albedo map computed iteratively.")

        hdu_out = fits.PrimaryHDU(new_cube, header=header)
        hdu_out.writeto(output_fits_path, overwrite=True)

    print(f"Final albedo map saved to: {output_fits_path}")

# --- Run Pipeline Over All FITS Cubes ---
fits_directory = "/home/pth/WORKSHOP/EARTHSHINE_CODE/OUTPUT/CUBES/"
output_fits_path = "final_albedo_map.fits"

iterative_solve(fits_directory, output_fits_path)

