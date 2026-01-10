import re
import numpy as np
from astropy.io import fits
from astropy.time import Time
from astroquery.jplhorizons import Horizons
import os
import matplotlib.pyplot as plt


import numpy as np
import matplotlib.pyplot as plt
from astropy.io import fits

def show_and_save_2d_array(array, label_str, cmap="jet", vmin=None, vmax=None):
    """
    Displays a 2D array as a color image with a legend and saves it as a 16-bit floating-point FITS file.

    Parameters:
        array (np.ndarray): The 2D array to display and save.
        label_str (str): Label used for plot title and FITS file naming.
        cmap (str): Colormap for visualization (default: 'jet').
        vmin (float or None): Minimum value for color scaling.
        vmax (float or None): Maximum value for color scaling.
    """
    # Define FITS filename
    fits_filename = f"{label_str.replace(' ', '_').lower()}.fits"

    # ✅ Show Image
    plt.figure(figsize=(8, 6))
    img = plt.imshow(array, cmap=cmap, origin='lower', vmin=vmin, vmax=vmax)
    cbar = plt.colorbar(img)
    cbar.set_label(f"{label_str} Value")
    plt.title(f"{label_str} Map")
    plt.xlabel("X (pixels)")
    plt.ylabel("Y (pixels)")
    plt.show()

    # ✅ Save FITS File (16-bit floating point)
    hdu = fits.PrimaryHDU(array.astype(np.float32))  # Ensure 32-bit float
    hdu.header['COMMENT'] = f"{label_str} saved as FITS."
    hdu.writeto(fits_filename, overwrite=True)

    print(f"Saved FITS file: {fits_filename}")


def get_julian_date_from_filename(filename):
    """
    Extracts Julian Date (JD) from a filename using `_JD` as an identifier.

    Parameters:
    filename (str): Filename containing JD.

    Returns:
    float: Extracted Julian Date.

    Raises:
    ValueError: If JD is not found.
    """
    match = re.search(r"_JD(\d+\.\d+)", filename)
    if match:
        return float(match.group(1))  # Extract JD

    match = re.search(r"245\d+\.\d+", filename)
    if match:
        return float(match.group())

    return None  # Return None if JD is not found


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

    eph = Horizons(id=moon_id, location=obs_id, epochs=julian_date).ephemerides()
    
    return np.radians(float(eph['alpha']))  # Convert degrees to radians

def compute_azimuthal_angle(incidence_map, emission_map, phase_angle):
    """
    Computes the azimuthal angle (φ) for each pixel in the image, ensuring correct unit conversion and stability.
    """
    azimuthal_angle_map = np.full(incidence_map.shape, np.nan, dtype=np.float32)  # Use NaN instead of -999

    valid_mask = (incidence_map > 0) & (emission_map > 0)  # Ensure valid values only

    # ✅ Convert degrees to radians
    i_rad = np.radians(incidence_map[valid_mask])
    e_rad = np.radians(emission_map[valid_mask])
    alpha_rad = np.radians(phase_angle)

    # ✅ Print Min/Max Differences in Incidence & Emission Angles
    print(f"Min/Max of (i_rad - e_rad): {np.nanmin(i_rad - e_rad):.6f}, {np.nanmax(i_rad - e_rad):.6f}")

    # ✅ Compute denominator safely
    denom = np.sin(i_rad) * np.sin(e_rad)

    # ✅ Print min/max values for denom
    print(f"Denominator (before filtering): min={np.nanmin(denom):.8f}, max={np.nanmax(denom):.8f}")
    print(f"Denominator (mean, median): mean={np.nanmean(denom):.8f}, median={np.nanmedian(denom):.8f}")

    denom = np.where(np.abs(denom) < 1e-6, np.nan, denom)  # Avoid near-zero division errors

    # ✅ Compute cos(phi) correctly (before clipping)
    cos_phi = (np.cos(alpha_rad) - np.cos(i_rad) * np.cos(e_rad)) / denom
    print(f"Cos(Phi) (before clipping): min={np.nanmin(cos_phi):.8f}, max={np.nanmax(cos_phi):.8f}")

    # ✅ Show cos_phi before clipping
    cos_phi_map = np.full(incidence_map.shape, np.nan, dtype=np.float32)
    cos_phi_map[valid_mask] = cos_phi

    plt.figure(figsize=(8, 6))
    plt.imshow(cos_phi_map, cmap='coolwarm', origin='lower', vmin=-1, vmax=1)
    plt.colorbar(label='Cos(Phi) Before Clipping')
    plt.title("Cos(Phi) Map (Before Clipping)")
    plt.show()

    # ✅ Clip cos_phi safely
    cos_phi = np.clip(cos_phi, -1, 1)

    # ✅ Compute azimuthal angle in degrees
    azimuthal_angle_map[valid_mask] = np.degrees(np.arccos(cos_phi))

    print(f"Azimuthal Angle (min, max): {np.nanmin(azimuthal_angle_map):.4f}, {np.nanmax(azimuthal_angle_map):.4f}")

    # ✅ Show the azimuthal angle map
    plt.figure(figsize=(8, 6))
    plt.imshow(azimuthal_angle_map, cmap='jet', origin='lower')
    plt.colorbar(label='Azimuthal Angle (degrees)')
    plt.title("Azimuthal Angle Map")
    plt.show()

    return azimuthal_angle_map


def combine_fits_to_cube(filenames, output_path):
    """
    Stacks multiple FITS files into a 3D cube and writes it to a new FITS file.

    Parameters:
    filenames (list of str): List of FITS file paths to combine.
    output_path (str): Path to save the combined FITS cube.
    """
    image_list = []
    original_header = None
    julian_date = None

    for i, file in enumerate(filenames):
        with fits.open(file) as hdul:
            img = hdul[0].data

            if original_header is None:
                original_header = hdul[0].header.copy()

            if len(img.shape) == 2:
                img = img[np.newaxis, :, :]

            image_list.append(img)

            # Extract JD from one of the input files
            if julian_date is None:
                jd = get_julian_date_from_filename(os.path.basename(file))
                if jd:
                    julian_date = jd

    if julian_date is None:
        raise ValueError("Julian Date could not be extracted from any input file.")

    fits_cube = np.vstack(image_list)

    for i, file in enumerate(filenames):
        original_header.add_comment(f"Layer {i+1} from file: {os.path.basename(file)}")

    hdu = fits.PrimaryHDU(fits_cube, header=original_header)
    hdu.writeto(output_path, overwrite=True)
    
    print(f"FITS cube saved to: {output_path}")

    return julian_date  # Return JD for later use


def process_lunar_cube(fits_cube_path, incidence_layer, emission_layer, julian_date, output_fits):
    """
    Reads a 3D FITS cube, computes the azimuthal angle, and appends it as a new layer.

    Parameters:
    fits_cube_path (str): Path to the FITS file containing the 3D cube.
    incidence_layer (int): Index of the incidence angle layer in the cube.
    emission_layer (int): Index of the emission angle layer in the cube.
    julian_date (float): Observation time in Julian Days.
    output_fits (str): Path to save the updated FITS cube.
    """
    with fits.open(fits_cube_path, mode='update') as hdu:
        data_cube = hdu[0].data
        header = hdu[0].header  

        # Get phase angle
        phase_angle = get_phase_angle(julian_date)
        print(f"Computed Phase Angle: {np.degrees(phase_angle):.2f} degrees ({phase_angle:.4f} radians)")

        # Extract incidence and emission maps
        incidence_map = data_cube[incidence_layer, :, :]
        emission_map = data_cube[emission_layer, :, :]

        # Compute azimuthal angle
        azimuthal_angle_map = compute_azimuthal_angle(incidence_map, emission_map, phase_angle)


        # save and show things
        show_and_save_2d_array(incidence_map, 'incidence', cmap="jet", vmin=None, vmax=None)
        show_and_save_2d_array(emission_map, 'emission', cmap="jet", vmin=None, vmax=None)
        show_and_save_2d_array(azimuthal_angle_map, 'azimuthal', cmap="jet", vmin=None, vmax=None)

        # Append new layer to the FITS cube
        new_cube = np.vstack([data_cube, azimuthal_angle_map[np.newaxis, :, :]])

        # Update header
        header.add_comment(f"Layer {new_cube.shape[0]}: Azimuthal angle (radians) computed from incidence/emission angles.")

        # Save the new FITS file
        hdu_out = fits.PrimaryHDU(new_cube, header=header)
        hdu_out.writeto(output_fits, overwrite=True)

        print(f"Updated FITS cube saved with azimuthal angle: {output_fits}")


# ---- Example Usage ----
fits_files = [
    "../EARTHSHINE_CODE/OUTPUT/IDEAL/ideal_LunarImg_SCA_0p34577230_JD_2455864.7415237_illfrac_0.1608.fit",
    "../EARTHSHINE_CODE/OUTPUT/LONLAT_AND_ANGLES_IMAGES/lonlatSELimage_JD2455864.7415237.fits",
    "../EARTHSHINE_CODE/OUTPUT/LONLAT_AND_ANGLES_IMAGES/Angles_JD2455864.7415237.fits",
    "../EARTHSHINE_CODE/OUTPUT/SUNMASK/SunMask_JD_2455864.7415237.fit"
]  
output_directory = "OUTPUT/CUBES/"
output_filename = "fits_cube.fits"
output_fits_path = os.path.join(output_directory, output_filename)

# Step 1: Build the FITS Cube and extract JD
julian_date = combine_fits_to_cube(fits_files, output_fits_path)

# Step 2: Compute Azimuthal Angle and Append as a New Layer
process_lunar_cube(output_fits_path, incidence_layer=0, emission_layer=2, julian_date=julian_date, output_fits="updated_fits_cube.fits")

