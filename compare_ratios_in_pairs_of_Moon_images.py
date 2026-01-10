from astropy.io import fits
import numpy as np

def read_fits_image(file_path):
    """
    Read a FITS image and return the data and header.
    """
    with fits.open(file_path) as hdul:
        # Force data type to be 16-bit floating-point
        data = hdul[0].data.astype(np.float16)
        header = hdul[0].header
    return data, header

# File paths
ideal_image_path = "./OUTPUT/IDEAL/ideal_LunarImg_SCA_0p584_JD_2455859.5000000_illfrac_0.0528.fit"
folded_image_path = "./OUTPUT/IDEAL/FOLDED_BUT_UNAUGMENTED/folded_ideal_LunarImg_SCA_0p584_JD_2455859.5000000_illfrac_0.0528.fit"

# Read FITS images
ideal_data, ideal_header = read_fits_image(ideal_image_path)
folded_data, folded_header = read_fits_image(folded_image_path)

# Print data types
print(f"Ideal Image Data Type: {ideal_data.dtype}")
print(f"Folded Image Data Type: {folded_data.dtype}")

