import sys
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

def generate_folded_image_path(ideal_image_path):
    """
    Generate the folded image path from the ideal image path.
    """
    # Split the path and filename
    path, filename = ideal_image_path.rsplit('/', 1)
    
    # Append the subdirectory and prepend 'folded_' to the filename
    folded_path = f"{path}/FOLDED_BUT_UNAUGMENTED/"
    folded_filename = f"folded_{filename}"
    
    # Combine the path and filename to get the full folded image path
    folded_image_path = f"{folded_path}{folded_filename}"
    
    return folded_image_path

if len(sys.argv) != 2:
    print("Usage: python script.py <ideal_image_path>")
    sys.exit(1)

# Get the ideal image path from the command line
ideal_image_path = sys.argv[1]

# Generate the folded image path
folded_image_path = generate_folded_image_path(ideal_image_path)

# Read FITS images
ideal_data, ideal_header = read_fits_image(ideal_image_path)
folded_data, folded_header = read_fits_image(folded_image_path)

# calculate a pixel ratio in both images and print to screen
rat1=ideal_data[215,144]/ideal_data[301,367]
rat2=folded_data[215,144]/folded_data[301,367]
print(rat1,rat2)
