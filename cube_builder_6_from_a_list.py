import numpy as np
import os
import matplotlib.pyplot as plt
from astropy.io import fits
from astropy.time import Time
from astroquery.jplhorizons import Horizons

# Function definitions remain unchanged
def get_julian_date_from_filename(filename):
    import re
    match = re.search(r"_JD(\d+\.\d+)", filename)
    if match:
        return float(match.group(1))

    match = re.search(r"245\d+\.\d+", filename)
    if match:
        return float(match.group())

    return None

def get_phase_angle(julian_date):
    """Fetches the phase angle (α) for a given Julian Date."""
    moon_id = '301'  # NASA HORIZONS ID for the Moon
    obs_id = '500'   # Earth-centered observer (geocentric)

    eph = Horizons(id=moon_id, location=obs_id, epochs=julian_date).ephemerides()
    return np.radians(float(eph['alpha']))  # Convert degrees to radians

def compute_azimuthal_angle(incidence_map, emergence_map, phase_angle):
    """Computes the azimuthal angle (φ) using incidence and emergence angles."""
    azimuthal_angle_map = np.full(incidence_map.shape, np.nan, dtype=np.float32)

    valid_mask = (incidence_map <= 3.141592653589/2.0) & (emergence_map != -999)  # Only valid pixels

    i_rad = incidence_map[valid_mask]  # Already in radians
    e_rad = emergence_map[valid_mask]  # Already in radians
    alpha_rad = phase_angle  # Already in radians

    denom = np.sin(i_rad) * np.sin(e_rad)
    denom = np.where(np.abs(denom) < 1e-6, np.nan, denom)  # Avoid division by zero

    cos_phi = (np.cos(alpha_rad) - np.cos(i_rad) * np.cos(e_rad)) / denom
    cos_phi = np.clip(cos_phi, -1, 1)

    azimuthal_angle_map[valid_mask] = np.degrees(np.arccos(cos_phi))
    return azimuthal_angle_map

def read_fits_files(filenames):
    """Reads multiple FITS files and assigns correct layers."""
    images = {}
    julian_date = None

    for file in filenames:
        with fits.open(file) as hdul:
            img = hdul[0].data
            filename = os.path.basename(file)

            if "ideal" in filename.lower():
                images["synthetic_moon"] = img  # 1 layer
            elif "lonlat" in filename.lower():
                images["longitude"] = img[0]  # First layer: Longitude
                images["latitude"] = img[1]   # Second layer: Latitude
            elif "angles" in filename.lower():
                images["incidence_angle"] = img[0]  # First layer: Incidence Angle
                images["emergence_earth"] = img[1]  # Second layer: Emergence (toward Earth's center)
                images["emergence_observer"] = img[2]  # Third layer: Emergence (toward observer)
            elif "sunmask" in filename.lower():
                images["sun_mask"] = img  # 1 layer

            if julian_date is None:
                jd = get_julian_date_from_filename(filename)
                if jd:
                    julian_date = jd

    if julian_date is None:
        raise ValueError("Julian Date could not be extracted.")

    return images, julian_date

def write_fits_cube(output_path, cube_data, header, layer_names):
    """Writes a 3D FITS cube containing all processed data layers."""
    header.add_comment("3D FITS Cube: Synthetic Moon, Lon/Lat, Angles, Sun Mask, Azimuth")
    
    for i, name in enumerate(layer_names):
        header.add_comment(f"Layer {i+1}: {name}")

    hdu = fits.PrimaryHDU(cube_data, header=header)
    hdu.writeto(output_path, overwrite=True)
    print(f"Final FITS cube saved to: {output_path}")

def process_all_julian_dates(matched_files_txt, output_directory):
    """
    Reads the matched_files.txt file, processes each set of 4 FITS files, 
    and builds a 3D FITS cube for each Julian Date.
    """
    with open(matched_files_txt, "r") as f:
        for line in f:
            files = line.strip().split()  # Read the 4 files from the line

            if len(files) != 4:
                print(f"❌ Error: Found {len(files)} files in line, expected 4. Skipping.")
                continue

            print(f"✅ Processing files:\n{files}")

            # Step 1: Read FITS files
            images, julian_date = read_fits_files(files)

            # Step 2: Compute Phase Angle
            phase_angle = get_phase_angle(julian_date)
            print(f"Computed Phase Angle: {np.degrees(phase_angle):.2f} degrees")

            # Step 3: Extract Required Maps for Azimuth Calculation
            if "incidence_angle" in images and "emergence_observer" in images:
                incidence_map = images["incidence_angle"]
                emergence_map = images["emergence_observer"]
            else:
                print(f"❌ Error: Missing required angle maps for JD {julian_date}. Skipping.")
                continue

            # Step 4: Compute Azimuthal Angle
            azimuthal_angle_map = compute_azimuthal_angle(incidence_map, emergence_map, phase_angle)

            # Step 5: Construct 3D Data Cube (All layers stacked)
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

            # Step 6: Write Final FITS Cube for this Julian Date
            output_fits_path = os.path.join(output_directory, f"fits_cube_JD_{julian_date}.fits")
            write_fits_cube(output_fits_path, fits_cube, fits.Header(), [
                "Synthetic Moon", "Longitude", "Latitude",
                "Incidence Angle", "Emergence (Earth)", "Emergence (Observer)",
                "Sun Mask", "Azimuthal Angle"
            ])

# ✅ Example Usage
matched_files_txt = "use_this_matched_files.txt"  # 🔧 File containing the 4-column list of FITS files
output_directory = "./OUTPUT/CUBES/"  # 🔧 Directory to save the generated FITS cubes

# Ensure output directory exists
os.makedirs(output_directory, exist_ok=True)

process_all_julian_dates(matched_files_txt, output_directory)

