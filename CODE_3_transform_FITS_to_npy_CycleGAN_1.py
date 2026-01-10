import os
from astropy.io import fits
import numpy as np

#
# Converts FITS in DomainA (Observed) adn DOmainB (ideal) to npy arrays
#

# Paths to FITS files
observed_dir = os.path.expanduser("~/SCALED_IMAGES/CycleGAN/DomainA/")
ideal_dir = os.path.expanduser("~/SCALED_IMAGES/CycleGAN/DomainB/")
output_dir = os.path.expanduser("~/SCALED_IMAGES/NumPy/")
os.makedirs(output_dir, exist_ok=True)

# Load FITS files and save as NumPy arrays
def fits_to_numpy(fits_dir, output_file):
    data_arrays = []
    for fits_file in os.listdir(fits_dir):
        if fits_file.endswith(".fits"):
            with fits.open(os.path.join(fits_dir, fits_file)) as hdul:
                data = hdul[0].data.astype(np.float32)  # Ensure consistent data type
                data_arrays.append(data)
    
    # Save all arrays as a single .npy file
    np.save(output_file, np.array(data_arrays))

# Convert Observed and Ideal datasets
fits_to_numpy(observed_dir, os.path.join(output_dir, "DomainA.npy"))
fits_to_numpy(ideal_dir, os.path.join(output_dir, "DomainB.npy"))

print("Data successfully saved as NumPy arrays.")

