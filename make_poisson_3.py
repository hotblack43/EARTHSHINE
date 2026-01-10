import os
import sys
import numpy as np
from astropy.io import fits

if len(sys.argv) != 3:
    print("Usage: python script.py <input_fits_file> <output_fits_file>")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]

# Read the input image and header from a FITS file
input_data, input_header = fits.getdata(input_file, header=True)
input_image = input_data.astype(np.float32)
input_image = input_image / np.max(input_image) * 50000.0

# Generate Poisson-distributed numbers for each pixel based on the input image
poisson_values = np.random.poisson(input_image).astype(np.float32)

# Get the directory part of the input file path
output_dir = os.path.dirname(input_file)

# Append the directory to the output file name
output_file = os.path.join(output_dir, output_file)

# Save the output image with the same header as the input file
output_hdu = fits.PrimaryHDU(poisson_values, header=input_header)
output_hdu.writeto(output_file, overwrite=True)

# Save the input image scaled
output_hdu = fits.PrimaryHDU(input_image, header=input_header)
output_hdu.writeto('scaled_input_image.fits', overwrite=True)

