import os
from astropy.io import fits
import numpy as np
import shutil

# 
# Collects the observed images and the generated synthetic ones and puts them into SCALED_IMAGES/
#

# Paths
observed_dir = os.path.expanduser("~/DARKCURRENTREDUCED/SELECTED_4b/")
ideal_dir = os.path.expanduser("~/WORKSHOP/EARTHSHINE_CODE/OUTPUT/IDEAL/")
output_dir = os.path.expanduser("~/SCALED_IMAGES/")
os.makedirs(output_dir, exist_ok=True)

# Get lists of files
observed_files = [f for f in os.listdir(observed_dir) if f.endswith(".fits")]
ideal_files = [f for f in os.listdir(ideal_dir) if f.endswith(".fit")]

# Renaming, flipping, and scaling
for observed_file in observed_files:
    # Extract JD from the observed filename
    observed_jd = observed_file.split("MOON_")[0]

    # Find the corresponding ideal image
    matching_ideal = next((f for f in ideal_files if f"JD_{observed_jd}" in f), None)
    if matching_ideal:
        # Rename the ideal image to match the observed JD format
        new_ideal_name = f"{observed_jd}IDEAL.fits"
        shutil.copy2(os.path.join(ideal_dir, matching_ideal), os.path.join(output_dir, new_ideal_name))

        # Scale and save the observed image
        with fits.open(os.path.join(observed_dir, observed_file)) as obs_hdu:
            obs_data = obs_hdu[0].data.astype(float)
            min_pixel, max_pixel = np.min(obs_data), np.max(obs_data)
            scaled_obs = 2 * (obs_data - min_pixel) / (max_pixel - min_pixel) - 1

            # Save the scaled observed image
            obs_hdu[0].data = scaled_obs
            scaled_obs_name = f"{observed_jd}OBSERVED_SCALED.fits"
            obs_hdu.writeto(os.path.join(output_dir, scaled_obs_name), overwrite=True)

        # Scale, flip vertically, and save the ideal image
        with fits.open(os.path.join(output_dir, new_ideal_name)) as ideal_hdu:
            ideal_data = ideal_hdu[0].data.astype(float)

            # Flip the ideal image vertically
            ideal_data = np.flipud(ideal_data)

            # Scale the ideal image
            min_pixel, max_pixel = np.min(ideal_data), np.max(ideal_data)
            scaled_ideal = 2 * (ideal_data - min_pixel) / (max_pixel - min_pixel) - 1

            # Save the scaled and flipped ideal image
            ideal_hdu[0].data = scaled_ideal
            ideal_hdu.writeto(os.path.join(output_dir, new_ideal_name), overwrite=True)

print("Renaming, scaling, and vertical flipping complete.")

