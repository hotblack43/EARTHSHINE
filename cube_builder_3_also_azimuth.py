import numpy as np
import os
import matplotlib.pyplot as plt
from astropy.io import fits
from astropy.time import Time
from astroquery.jplhorizons import Horizons


def get_julian_date_from_filename(filename):
    """Extracts Julian Date (JD) from a filename using `_JD` as an identifier."""
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


def compute_azimuthal_angle(incidence_map, emission_map, phase_angle):
    """Computes the azimuthal angle (φ) using the correct equations."""
    azimuthal_angle_map = np.full(incidence_map.shape, np.nan, dtype=np.float32)

    valid_mask = (incidence_map > 0) & (emission_map > 0)

    i_rad = np.radians(incidence_map[valid_mask])
    e_rad = np.radians(emission_map[valid_mask])
    alpha_rad = phase_angle

    denom = np.sin(i_rad) * np.sin(e_rad)
    denom = np.where(np.abs(denom) < 1e-6, np.nan, denom)  # Avoid division by zero

    cos_phi = (np.cos(alpha_rad) - np.cos(i_rad) * np.cos(e_rad)) / denom
    cos_phi = np.clip(cos_phi, -1, 1)

    azimuthal_angle_map[valid_mask] = np.degrees(np.arccos(cos_phi))

    return azimuthal_angle_map


def read_fits_files(filenames):
    """Reads multiple FITS files and assigns correct layers based on known structure."""
    images = {}
    julian_date = None

    for file in filenames:
        with fits.open(file) as hdul:
            img = hdul[0].data
            filename = os.path.basename(file)

            # Identify which map this is
            if "ideal" in filename.lower():
                images["reflectance"] = img
                print(f"Loaded Reflectance Image from {filename}")
            elif "lonlat" in filename.lower():
                images["lonlat"] = img
                print(f"Loaded Longitude/Latitude Image from {filename}")
            elif "angles" in filename.lower():
                images["angles"] = img
                print(f"Loaded Angle Map from {filename}")
            elif "sunmask" in filename.lower():
                images["sunmask"] = img
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
    header.add_comment("3D FITS Cube: Reflectance, Angles, Sun Mask, Azimuth")
    
    for i, name in enumerate(layer_names):
        header.add_comment(f"Layer {i+1}: {name}")

    hdu = fits.PrimaryHDU(cube_data, header=header)
    hdu.writeto(output_path, overwrite=True)

    print(f"Final FITS cube saved to: {output_path}")


# ---- Example Usage ----
fits_files = [
    "ideal_LunarImg_SCA_0p34577230_JD_2455864.7415237_illfrac_0.1608.fit",
    "lonlatSELimage_JD2455864.7415237.fits",
    "Angles_JD2455864.7415237.fits",
    "SunMask_JD_2455864.7415237.fit"
]  
output_fits_path = "final_fits_cube.fits"

# Step 1: Read FITS files and extract relevant data
images, julian_date = read_fits_files(fits_files)

# Step 2: Compute Phase Angle
phase_angle = get_phase_angle(julian_date)
print(f"Computed Phase Angle: {np.degrees(phase_angle):.2f} degrees ({phase_angle:.4f} radians)")

# Step 3: Extract Required Maps for Azimuth Calculation
if "angles" in images:
    incidence_map = images["angles"][0]  # Assuming first layer is Incidence
    emission_map = images["angles"][2]  # Assuming third layer is Emission
else:
    raise ValueError("Error: No angle maps found!")

# Step 4: Compute Azimuthal Angle
azimuthal_angle_map = compute_azimuthal_angle(incidence_map, emission_map, phase_angle)

# Step 5: Construct 3D Data Cube (All layers stacked)
fits_cube = np.stack([
    images["reflectance"],  # Layer 1: Reflectance Image
    incidence_map,          # Layer 2: Incidence Angle Map
    emission_map,           # Layer 3: Emission Angle Map
    images["sunmask"],      # Layer 4: Sun Mask
    azimuthal_angle_map     # Layer 5: Computed Azimuthal Angle
], axis=0)

# Step 6: Write Final FITS Cube
write_fits_cube(output_fits_path, fits_cube, fits.Header(), ["Reflectance", "Incidence", "Emission", "Sun Mask", "Azimuth"])

