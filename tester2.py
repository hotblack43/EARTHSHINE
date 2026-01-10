import numpy as np
from astropy.io import fits
from astropy.time import Time
from astroquery.jplhorizons import Horizons

def get_phase_angle(julian_date):
    """
    Fetches the phase angle (α) of the Moon at a given Julian Date using NASA's HORIZONS system.

    Parameters:
    julian_date (float): Observation time in Julian Days.

    Returns:
    float: Phase angle (radians).
    """
    moon_id = '301'  # NASA HORIZONS ID for the Moon
    obs_id = '500'   # Earth-centered observer (geocentric)

    # Query ephemeris
    eph = Horizons(id=moon_id, location=obs_id, epochs=julian_date).ephemerides()
    
    # Convert degrees to radians
    return np.radians(float(eph['alpha']))  # Extract phase angle in radians


def compute_azimuthal_angle(incidence_map, emission_map, phase_angle):
    """
    Computes the azimuthal angle (φ) for each pixel in the image, skipping sky pixels.

    Parameters:
    incidence_map (2D array): Incidence angle (radians) for each pixel.
    emission_map (2D array): Emission angle (radians) for each pixel.
    phase_angle (float): Phase angle (radians) for the entire image.

    Returns:
    azimuthal_angle_map (2D array): Azimuthal angle (radians) with sky pixels preserved (-999).
    """
    # Initialize output array with -999 (same shape as input images)
    azimuthal_angle_map = np.full(incidence_map.shape, -999.0, dtype=np.float32)

    # Create a mask for valid pixels (where incidence and emission angles are not -999 or 0)
    valid_mask = (incidence_map > 0) & (emission_map > 0)

    # Compute cosine of azimuthal angle safely (only for valid pixels)
    i_rad = incidence_map[valid_mask]  # Already in radians
    e_rad = emission_map[valid_mask]   # Already in radians
    alpha_rad = phase_angle             # Already in radians

    denom = np.sin(i_rad) * np.sin(e_rad)

    # Avoid divide-by-zero issues
    denom[denom == 0] = np.nan

    cos_phi = (np.cos(alpha_rad) - np.cos(i_rad) * np.cos(e_rad)) / denom
    
    # Clip values to avoid numerical errors
    cos_phi = np.clip(cos_phi, -1, 1)

    # Compute azimuthal angle in radians (only for valid pixels)
    azimuthal_angle_map[valid_mask] = np.arccos(cos_phi)

    return azimuthal_angle_map


def process_lunar_cube(fits_cube_path, incidence_layer, emission_layer, julian_date, output_fits):
    """
    Reads a 3D FITS cube, extracts the incidence and emission angle layers, computes the azimuthal angle, 
    and saves the result as a FITS file. The sky pixels remain -999.

    Parameters:
    fits_cube_path (str): Path to the FITS file containing the 3D cube.
    incidence_layer (int): Index of the incidence angle layer in the cube.
    emission_layer (int): Index of the emission angle layer in the cube.
    julian_date (float): Observation time in Julian Days.
    output_fits (str): Path to save the computed azimuthal angle FITS file.
    """
    # Load the FITS cube
    with fits.open(fits_cube_path) as hdu:
        data_cube = hdu[0].data
        header = hdu[0].header  # Copy header for metadata
        
    # Extract the incidence and emission angle maps
    incidence_map = data_cube[incidence_layer, :, :]
    emission_map = data_cube[emission_layer, :, :]

    # Get phase angle from NASA HORIZONS (already in radians)
    phase_angle = get_phase_angle(julian_date)
    print(f"Computed Phase Angle: {np.degrees(phase_angle):.2f} degrees ({phase_angle:.4f} radians)")

    # Compute azimuthal angle
    azimuthal_angle_map = compute_azimuthal_angle(incidence_map, emission_map, phase_angle)

    # Save to a 32-bit FITS file (preserving sky pixels as -999)
    hdu_out = fits.PrimaryHDU(data=azimuthal_angle_map.astype(np.float32), header=header)
    hdu_out.writeto(output_fits, overwrite=True)
    print(f"Saved azimuthal angle FITS file: {output_fits}")


# Example Usage
fits_cube_path = "../EARTHSHINE_CODE/OUTPUT/LONLAT_AND_ANGLES_IMAGES/Angles_JD2455864.7415237.fits"  # Path to your 3D FITS cube
incidence_layer_idx = 0  # Example: 0th layer contains incidence angles
emission_layer_idx = 1   # Example: 1st layer contains emission angles
julian_date_observed = 2455864.7415237  # Example Julian Date (Replace with actual observation time)
output_fits_path = "azimuthal_angle.fits"


# Process the lunar cube and save the azimuthal angle map
process_lunar_cube(fits_cube_path, incidence_layer_idx, emission_layer_idx, julian_date_observed, output_fits_path)

