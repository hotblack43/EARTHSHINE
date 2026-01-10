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
def load_fits_data(fits_cube_path, angle_units="unknown"):
    """
    Loads radiance, incidence, emergence, and azimuth angles from a 3D FITS cube.
    Converts azimuth from degrees to radians (incidence & emergence remain in radians).
    
    Returns:
    - Valid pixel indices, masked data, and phase angle.
    """
    with fits.open(fits_cube_path) as hdu:
        data_cube = hdu[0].data
        header = hdu[0].header  

        julian_date = get_julian_date_from_filename(os.path.basename(fits_cube_path))
        phase_angle = get_phase_angle(julian_date)

        radiance_map = data_cube[0, :, :]  # Layer 1: Radiance
        incidence_map = data_cube[3, :, :]  # Layer 4: Incidence Angle (already in radians)
        emergence_map = data_cube[5, :, :]  # Layer 6: Emergence Angle (already in radians)
        azimuth_map = data_cube[7, :, :]  # Layer 8: Azimuthal Angle (in degrees)

        # Convert azimuth angle ONLY (since incidence & emergence are already in radians)
        azimuth_map = np.radians(azimuth_map)  # Convert from degrees to radians

        # Apply mask: Ignore sky pixels (radiance, incidence, or emergence == 0) and NaN azimuth values
        valid_mask = (radiance_map > 0) & (incidence_map > 0) & (emergence_map > 0) & (~np.isnan(azimuth_map))

        print("\n🔍 **Angle Data Check for:**", fits_cube_path)
        print(f" - Julian Date: {julian_date}")
        print(f" - Computed Phase Angle: {np.degrees(phase_angle):.2f}° ({phase_angle:.4f} radians)")
        print(f" - Incidence Angle: min={np.min(incidence_map):.4f}, max={np.max(incidence_map):.4f} (Already in radians)")
        print(f" - Emergence Angle: min={np.min(emergence_map):.4f}, max={np.max(emergence_map):.4f} (Already in radians)")
        print(f" - Azimuth Angle: min={np.nanmin(azimuth_map):.4f}, max={np.nanmax(azimuth_map):.4f} (Converted to radians)")

    return valid_mask, radiance_map, incidence_map, emergence_map, azimuth_map, phase_angle, julian_date

def new_load_fits_data(fits_cube_path, angle_units="unknown"):
    """
    Loads radiance, incidence, emergence, and azimuth angles from a 3D FITS cube.
    Prints min/max values to check if units are in degrees or radians.
    
    Parameters:
    - fits_cube_path (str): Path to the FITS cube.
    - angle_units (str): "unknown", "degrees" or "radians".
    
    Returns:
    - Valid pixel indices, masked data, and phase angle.
    """
    with fits.open(fits_cube_path) as hdu:
        data_cube = hdu[0].data
        header = hdu[0].header  

        julian_date = get_julian_date_from_filename(os.path.basename(fits_cube_path))
        phase_angle = get_phase_angle(julian_date)

        radiance_map = data_cube[0, :, :]  # Layer 1: Radiance
        incidence_map = data_cube[3, :, :]  # Layer 4: Incidence Angle
        emergence_map = data_cube[5, :, :]  # Layer 6: Emergence Angle
        azimuth_map = data_cube[7, :, :]  # Layer 8: Azimuthal Angle

        # Print angle statistics to determine if they are in degrees or radians
        print("\n🔍 **Angle Data Check for:**", fits_cube_path)
        print(f" - Julian Date: {julian_date}")
        print(f" - Computed Phase Angle: {np.degrees(phase_angle):.2f}° ({phase_angle:.4f} radians)")

        print(f" - Incidence Angle: min={np.min(incidence_map):.4f}, max={np.max(incidence_map):.4f}")
        print(f" - Emergence Angle: min={np.min(emergence_map):.4f}, max={np.max(emergence_map):.4f}")
        print(f" - Azimuth Angle: min={np.nanmin(azimuth_map):.4f}, max={np.nanmax(azimuth_map):.4f} (NaNs exist?)")

        # Check if the angles might be in degrees
        if np.max(incidence_map) > np.pi or np.max(emergence_map) > np.pi:
            print("⚠️ **Warning:** Angles appear to be in DEGREES! Consider conversion to radians.")
        else:
            print("✅ Angles are likely in RADIANS.")

        return radiance_map, incidence_map, emergence_map, azimuth_map, phase_angle, julian_date

def old_load_fits_data(fits_cube_path, angle_units="degrees"):
    """
    Loads radiance, incidence, emergence, and azimuth angles from a 3D FITS cube.
    Masks out sky pixels (0) and NaN azimuth values.
    
    Parameters:
    - fits_cube_path (str): Path to the FITS cube.
    - angle_units (str): "degrees" or "radians".
    
    Returns:
    - Valid pixel indices, masked data, and phase angle.
    """
    with fits.open(fits_cube_path) as hdu:
        data_cube = hdu[0].data
        header = hdu[0].header  

        julian_date = get_julian_date_from_filename(os.path.basename(fits_cube_path))
        phase_angle = get_phase_angle(julian_date)

        radiance_map = data_cube[0, :, :]  # Layer 1: Radiance
        incidence_map = data_cube[3, :, :]  # Layer 4: Incidence Angle
        emergence_map = data_cube[5, :, :]  # Layer 6: Emergence Angle
        azimuth_map = data_cube[7, :, :]  # Layer 8: Azimuthal Angle

        # Convert angles if needed
        if angle_units == "degrees":
            incidence_map = np.radians(incidence_map)
            emergence_map = np.radians(emergence_map)
            azimuth_map = np.radians(azimuth_map)

        # Apply mask: Ignore sky pixels (radiance, incidence, or emergence == 0) and NaN azimuth values
        valid_mask = (radiance_map > 0) & (incidence_map > 0) & (emergence_map > 0) & (~np.isnan(azimuth_map))

    return valid_mask, radiance_map, incidence_map, emergence_map, azimuth_map, phase_angle, julian_date

# --- Step 4: Initialize BRDF Interpolation ---
def initialize_brdf(angles, reflectance_values):
    return interp.LinearNDInterpolator(angles, reflectance_values)

# --- Step 5: Solve for Albedo ---
def update_albedo(incidence, emergence, phase_angle, observed_radiance, brdf_func):
    def cost_function(albedo):
        modeled_radiance = albedo * brdf_func([incidence, emergence, phase_angle])
        return np.abs(modeled_radiance - observed_radiance)
    
    result = opt.minimize_scalar(cost_function, bounds=(0.01, 1.0), method='bounded')
    return result.x

# --- Step 6: Solve for BRDF ---
def update_brdf(incidence_map, emergence_map, phase_angle, radiance_map, albedo_map, valid_mask):
    """
    Updates BRDF function while ensuring numerical stability.
    Uses NearestNDInterpolator if LinearNDInterpolator fails.
    """
    valid_pixels = valid_mask.flatten()
    
    if np.sum(valid_pixels) < 10:  # Not enough valid data points
        print("Warning: Too few valid pixels for BRDF estimation. Returning default function.")
        return lambda x: np.mean(radiance_map[valid_mask] / albedo_map[valid_mask])  # Return a constant function

    # Construct input data points
    angles = np.vstack([
        incidence_map.flatten()[valid_pixels], 
        emergence_map.flatten()[valid_pixels], 
        np.full(np.sum(valid_pixels), phase_angle)
    ]).T
    brdf_values = radiance_map.flatten()[valid_pixels] / albedo_map.flatten()[valid_pixels]

    # Try using LinearNDInterpolator first
    try:
        brdf_func = interp.LinearNDInterpolator(angles, brdf_values)
    except Exception as e:
        print(f"LinearNDInterpolator failed: {e}. Switching to NearestNDInterpolator.")
        brdf_func = interp.NearestNDInterpolator(angles, brdf_values)

    return brdf_func


def old_update_brdf(incidence_map, emergence_map, phase_angle, radiance_map, albedo_map, valid_mask):
    valid_pixels = valid_mask.flatten()
    angles = np.vstack([
        incidence_map.flatten()[valid_pixels], 
        emergence_map.flatten()[valid_pixels], 
        np.full(valid_pixels.sum(), phase_angle)
    ]).T
    brdf_values = radiance_map.flatten()[valid_pixels] / albedo_map.flatten()[valid_pixels]
    return interp.LinearNDInterpolator(angles, brdf_values)

# --- Step 7: Iterative Albedo & BRDF Estimation Over All FITS Cubes ---
def iterative_solve(fits_directory, output_fits_path, angle_units="degrees", max_iterations=10):
    """
    Iteratively estimates albedo map and BRDF function across multiple FITS cubes.
    Only valid pixels (sunlit lunar surface) are used.
    """
    fits_files = sorted(glob.glob(os.path.join(fits_directory, "*.fits")))

    if not fits_files:
        raise ValueError("No FITS files found in directory.")

    all_albedo_maps = []
    all_phase_angles = []

    for idx, fits_cube_path in enumerate(fits_files):
        print(f"Processing {fits_cube_path} ({idx+1}/{len(fits_files)})")

        valid_mask, radiance_map, incidence_map, emergence_map, azimuth_map, phase_angle, julian_date = load_fits_data(fits_cube_path, angle_units)
        all_phase_angles.append(phase_angle)

        if idx == 0:
            albedo_map = np.ones_like(radiance_map) * 0.1  # Initial guess
            brdf_func = update_brdf(incidence_map, emergence_map, phase_angle, radiance_map, albedo_map, valid_mask)

        for iteration in range(max_iterations):
            print(f"Iteration {iteration + 1}")

            # Step 7A: Solve for albedo per pixel
            for i in range(incidence_map.shape[0]):
                for j in range(incidence_map.shape[1]):
                    if valid_mask[i, j]:  # Only solve for valid pixels
                        albedo_map[i, j] = update_albedo(incidence_map[i, j], emergence_map[i, j], phase_angle, radiance_map[i, j], brdf_func)

            # Step 7B: Solve for BRDF given updated albedo map
            brdf_func = update_brdf(incidence_map, emergence_map, phase_angle, radiance_map, albedo_map, valid_mask)

            # Step 7C: Check for convergence
            if np.max(np.abs(albedo_map[valid_mask] - albedo_map[valid_mask].mean())) < 0.001:
                break

        all_albedo_maps.append(albedo_map)

    final_albedo_map = np.mean(all_albedo_maps, axis=0)

    # Save updated albedo map as new FITS layer
    with fits.open(fits_files[0], mode='update') as hdu:
        new_cube = np.vstack([hdu[0].data, final_albedo_map[np.newaxis, :, :]])
        header = hdu[0].header
        header.add_comment(f"Layer {new_cube.shape[0]}: Final albedo map computed iteratively.")

        hdu_out = fits.PrimaryHDU(new_cube, header=header)
        hdu_out.writeto(output_fits_path, overwrite=True)

    print(f"Final albedo map saved to: {output_fits_path}")

# --- Run Pipeline ---
fits_directory = "/home/pth/WORKSHOP/EARTHSHINE_CODE/OUTPUT/CUBES/"
output_fits_path = "final_albedo_map.fits"

iterative_solve(fits_directory, output_fits_path, angle_units="degrees")

