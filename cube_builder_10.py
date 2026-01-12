import numpy as np
import os
import matplotlib.pyplot as plt
from astropy.io import fits
from astropy.time import Time
from astroquery.jplhorizons import Horizons

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
    print('trying to show ',label_str)
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
    """Extracts Julian Date (JD) from a filename using `_JD` as an identifier."""
    import re
    match = re.search(r"_JD(\d+\.\d+)", filename)
    if match:
        return float(match.group(1))

    match = re.search(r"245\d+\.\d+", filename)
    if match:
        return float(match.group())

    return None


def get_phase_angle(julian_date):
    """Fetches the phase angle (α) of the Moon at a given Julian Date using NASA's HORIZONS system."""
    moon_id = '301'  # NASA HORIZONS ID for the Moon
    obs_id = '500'   # Earth-centered observer (geocentric)

    eph = Horizons(id=moon_id, location=obs_id, epochs=julian_date).ephemerides()
    return np.radians(float(eph['alpha']))  # Convert degrees to radians

def compute_azimuthal_angle(incidence_map, emergence_map, phase_angle):
    """Computes the azimuthal angle (φ) using the correct incidence and emergence angles at each pixel."""
    azimuthal_angle_map = np.full(incidence_map.shape, np.nan, dtype=np.float32)

    # ✅ Ensure calculations are done only on valid pixels
    valid_mask = (incidence_map != -999) & (emergence_map != -999)

    #i_rad = np.radians(incidence_map[valid_mask])
    #e_rad = np.radians(emergence_map[valid_mask])
    i_rad = (incidence_map[valid_mask]) # in rad
    e_rad = (emergence_map[valid_mask]) # in rad
    alpha_rad = phase_angle  # Already in radians

    # ✅ Fix: Restore original 2D shape for visualization
    i_rad_full = np.full(incidence_map.shape, np.nan, dtype=np.float32)
    e_rad_full = np.full(emergence_map.shape, np.nan, dtype=np.float32)

    i_rad_full[valid_mask] = i_rad  # Restore incidence angle map
    e_rad_full[valid_mask] = e_rad  # Restore emergence angle map

    # ✅ Show inputs before continuing
    show_and_save_2d_array(i_rad_full, "i_rad (Incidence Angle in Radians)", cmap="jet")
    show_and_save_2d_array(e_rad_full, "e_rad (Emergence Angle in Radians)", cmap="jet")

    # ✅ Compute denominator safely
    denom = np.sin(i_rad) * np.sin(e_rad)
    denom = np.where(np.abs(denom) < 1e-6, np.nan, denom)  # Avoid division by zero

    # ✅ Restore denom to 2D shape
    denom_full = np.full(incidence_map.shape, np.nan, dtype=np.float32)
    denom_full[valid_mask] = denom

    # ✅ Show and save denom before using it in cos(phi) computation
    show_and_save_2d_array(denom_full, "Denominator (denom)", cmap="inferno")

    # ✅ Compute cos(phi)
    cos_phi = (np.cos(alpha_rad) - np.cos(i_rad) * np.cos(e_rad)) / denom

    # ✅ Restore cos_phi to 2D shape
    cos_phi_full = np.full(incidence_map.shape, np.nan, dtype=np.float32)
    cos_phi_full[valid_mask] = cos_phi

    # ✅ Show cos_phi before clipping
    show_and_save_2d_array(cos_phi_full, "Cos(Phi) Before Clipping", cmap="coolwarm", vmin=-1, vmax=1)

    cos_phi = np.clip(cos_phi, -1, 1)  # Clip values to ensure valid input for arccos

    # ✅ Compute azimuth in degrees
    azimuthal_angle_map[valid_mask] = np.degrees(np.arccos(cos_phi))

    # ✅ Show the azimuthal angle map
    show_and_save_2d_array(azimuthal_angle_map, "Azimuthal Angle Map", cmap="jet")

    return azimuthal_angle_map

def new_compute_azimuthal_angle(incidence_map, emergence_map, phase_angle):
    """Computes the azimuthal angle (φ) using the correct incidence and emergence angles at each pixel."""
    azimuthal_angle_map = np.full(incidence_map.shape, np.nan, dtype=np.float32)

    # ✅ Ensure calculations are done only on valid pixels
    valid_mask = (incidence_map > 0) & (emergence_map > 0)

    i_rad = np.radians(incidence_map[valid_mask])
    e_rad = np.radians(emergence_map[valid_mask])
    alpha_rad = phase_angle  # Already in radians

    # ✅ Fix: Restore original 2D shape for visualization
    i_rad_full = np.full(incidence_map.shape, np.nan, dtype=np.float32)
    e_rad_full = np.full(emergence_map.shape, np.nan, dtype=np.float32)

    i_rad_full[valid_mask] = i_rad  # Restore incidence angle map
    e_rad_full[valid_mask] = e_rad  # Restore emergence angle map

    # ✅ Show inputs before continuing
    show_and_save_2d_array(i_rad_full, "i_rad (Incidence Angle in Radians)", cmap="jet")
    show_and_save_2d_array(e_rad_full, "e_rad (Emergence Angle in Radians)", cmap="jet")

    # ✅ Compute denominator safely
    denom = np.sin(i_rad) * np.sin(e_rad)
    denom = np.where(np.abs(denom) < 1e-6, np.nan, denom)  # Avoid division by zero
    show_and_save_2d_array(denom, "denom", cmap="coolwarm", vmin=-1, vmax=1)

    # ✅ Compute cos(phi)
    cos_phi = (np.cos(alpha_rad) - np.cos(i_rad) * np.cos(e_rad)) / denom

    # ✅ Restore cos_phi to 2D shape
    cos_phi_full = np.full(incidence_map.shape, np.nan, dtype=np.float32)
    cos_phi_full[valid_mask] = cos_phi

    # ✅ Show cos_phi before clipping
    show_and_save_2d_array(cos_phi_full, "Cos(Phi) Before Clipping", cmap="coolwarm", vmin=-1, vmax=1)

    cos_phi = np.clip(cos_phi, -1, 1)  # Clip values to ensure valid input for arccos

    # ✅ Compute azimuth in degrees
    azimuthal_angle_map[valid_mask] = np.degrees(np.arccos(cos_phi))

    # ✅ Show the azimuthal angle map
    show_and_save_2d_array(azimuthal_angle_map, "Azimuthal Angle Map", cmap="jet")

    return azimuthal_angle_map


def old_compute_azimuthal_angle(incidence_map, emergence_map, phase_angle):
    """Computes the azimuthal angle (φ) using the correct incidence and emergence angles."""
    azimuthal_angle_map = np.full(incidence_map.shape, np.nan, dtype=np.float32)

    valid_mask = (incidence_map > 0) & (emergence_map > 0)

    i_rad = np.radians(incidence_map[valid_mask])
    e_rad = np.radians(emergence_map[valid_mask])
    alpha_rad = phase_angle
    print('phase angle',alpha_rad)

    denom = np.sin(i_rad) * np.sin(e_rad)
    denom = np.where(np.abs(denom) < 1e-6, np.nan, denom)  # Avoid division by zero

    cos_phi = (np.cos(alpha_rad) - np.cos(i_rad) * np.cos(e_rad)) / denom
    cos_phi = np.clip(cos_phi, -1, 1)

    azimuthal_angle_map[valid_mask] = np.degrees(np.arccos(cos_phi))
# plots and saves
    show_and_save_2d_array(i_rad, "i_rad", cmap="jet", vmin=None, vmax=None)
    show_and_save_2d_array(e_rad, "e_rad", cmap="jet", vmin=None, vmax=None)
    show_and_save_2d_array(denom, "denom", cmap="jet", vmin=None, vmax=None)
    


    return azimuthal_angle_map


def read_fits_files(filenames):
    """Reads multiple FITS files and explicitly assigns the correct layers for each dataset."""
    images = {}
    julian_date = None

    for file in filenames:
        with fits.open(file) as hdul:
            img = hdul[0].data
            filename = os.path.basename(file)

            # Identify which map this is
            if "ideal" in filename.lower():
                images["synthetic_moon"] = img  # 1 layer
                print(f"Loaded Synthetic Moon Image from {filename}")

            elif "lonlat" in filename.lower():
                images["longitude"] = img[0]  # First layer is longitude
                images["latitude"] = img[1]   # Second layer is latitude
                print(f"Loaded Longitude/Latitude from {filename} (2 layers)")

            elif "angles" in filename.lower():
                images["incidence_angle"] = img[0]  # First layer: Incidence Angle
                images["emergence_earth"] = img[1]  # Second layer: Emergence (toward Earth's center)
                images["emergence_observer"] = img[2]  # Third layer: Emergence (toward observer)
                print(f"Loaded Angle Map from {filename} (3 layers)")
                print(f" -> Incidence Angle assigned from Layer 1")
                print(f" -> Emergence (toward Earth’s center) assigned from Layer 2")
                print(f" -> Emergence (toward observer) assigned from Layer 3")

            elif "sunmask" in filename.lower():
                images["sun_mask"] = img  # 1 layer
                print(f"Loaded Sun Mask from {filename}")

            # Extract Julian Date if not set
            if julian_date is None:
                jd = get_julian_date_from_filename(filename)
                if jd:
                    julian_date = jd

    if julian_date is None:
        raise ValueError("Julian Date could not be extracted from any input file.")

    return images, julian_date


def write_fits_cube(output_path, cube_data, header, layer_names):
    """Writes a 3D FITS cube containing all processed data layers."""
    header.add_comment("3D FITS Cube: Synthetic Moon, Lon/Lat, Angles, Sun Mask, Azimuth")
    
    for i, name in enumerate(layer_names):
        header.add_comment(f"Layer {i+1}: {name}")

    hdu = fits.PrimaryHDU(cube_data, header=header)
    hdu.writeto(output_path, overwrite=True)

    print(f"Final FITS cube saved to: {output_path}")


# ---- Example Usage ----
fits_files = [
    "/dmidata/projects/nckf/earthshine/WORKSHOP/EARTHSHINE_CODE/OUTPUT/IDEAL/ideal_LunarImg_SCA_0p34577230_JD_2455864.7415237_illfrac_0.1608.fit",  # 1 layer
    "/dmidata/projects/nckf/earthshine/WORKSHOP/EARTHSHINE_CODE/OUTPUT/LONLAT_AND_ANGLES_IMAGES/lonlatSELimage_JD2455864.7415237.fits",  # 2 layers: Longitude & Latitude
    "/dmidata/projects/nckf/earthshine/WORKSHOP/EARTHSHINE_CODE/OUTPUT/LONLAT_AND_ANGLES_IMAGES/Angles_JD2455864.7415237.fits",  # 3 layers: Incidence, Emergence (Earth), Emergence (Observer)
    "/dmidata/projects/nckf/earthshine/WORKSHOP/EARTHSHINE_CODE/OUTPUT/SUNMASK/SunMask_JD_2455864.7415237.fit"  # 1 layer
]  
output_fits_path = "final_fits_cube.fits"

# Step 1: Read FITS files and extract relevant data
images, julian_date = read_fits_files(fits_files)

# Step 2: Compute Phase Angle
phase_angle = get_phase_angle(julian_date)
print(f"Computed Phase Angle: {np.degrees(phase_angle):.2f} degrees ({phase_angle:.4f} radians)")

# Step 3: Extract Required Maps for Azimuth Calculation
if "incidence_angle" in images and "emergence_observer" in images:
    incidence_map = images["incidence_angle"]  # First layer of Angles FITS file
    emergence_map = images["emergence_observer"]  # Third layer of Angles FITS file
else:
    raise ValueError("Error: Incidence or Emergence angle maps not found!")

# Step 4: Compute Azimuthal Angle
show_and_save_2d_array(incidence_map, 'incidence', cmap="jet", vmin=None, vmax=None)
show_and_save_2d_array(emergence_map, 'emergence', cmap="jet", vmin=None, vmax=None)
azimuthal_angle_map = compute_azimuthal_angle(incidence_map, emergence_map, phase_angle)
show_and_save_2d_array(azimuthal_angle_map, 'azimuth', cmap="jet", vmin=None, vmax=None)

# Step 5: Construct 3D Data Cube (All layers stacked in correct order)
fits_cube = np.stack([
    images["synthetic_moon"],  # Layer 1: Synthetic Moon Image
    images["longitude"],       # Layer 2: Longitude Map
    images["latitude"],        # Layer 3: Latitude Map
    images["incidence_angle"], # Layer 4: Incidence Angle
    images["emergence_earth"], # Layer 5: Emergence toward Earth's center
    images["emergence_observer"], # Layer 6: Emergence toward observer
    images["sun_mask"],        # Layer 7: Sun Mask
    azimuthal_angle_map        # Layer 8: Computed Azimuthal Angle
], axis=0)

# Step 6: Write Final FITS Cube
write_fits_cube(output_fits_path, fits_cube, fits.Header(), [
    "Synthetic Moon", "Longitude", "Latitude",
    "Incidence Angle", "Emergence (Earth)", "Emergence (Observer)",
    "Sun Mask", "Azimuthal Angle"
])

