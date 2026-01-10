from astropy.io import fits
import numpy as np
import os

def combine_fits_to_cube(filenames, output_dir, output_filename):
    """Stacks multiple FITS files into a 3D cube and writes it to a new FITS file."""
    
    image_list = []  # List to store image layers
    original_header = None  # Header from the first file to modify
    
    for i, file in enumerate(filenames):
        # Open FITS file and read image data
        with fits.open(file) as hdul:
            img = hdul[0].data  # Read image data
            
            # Save the header from the first file
            if original_header is None:
                original_header = hdul[0].header.copy()
            
            # Ensure img is 3D (convert 2D images into single-layer 3D arrays)
            if len(img.shape) == 2:
                img = img[np.newaxis, :, :]  # Add a new axis at the beginning
            
            # Append to the list
            image_list.append(img)
    
    # Stack images along the first dimension (layer stacking)
    fits_cube = np.vstack(image_list)  # Shape: (num_layers, height, width)
    
    # Update the header with comments listing input files
    for i, file in enumerate(filenames):
        original_header.add_comment(f"Layer {i+1} from file: {os.path.basename(file)}")
    
    # Define output file path
    output_path = os.path.join(output_dir, output_filename)
    
    # Create new FITS HDU and write the cube to disk
    hdu = fits.PrimaryHDU(fits_cube, header=original_header)
    hdu.writeto(output_path, overwrite=True)
    
    print(f"FITS cube saved to: {output_path}")

# ---- Define file paths ----
fits_files = ["../EARTHSHINE_CODE/OUTPUT/IDEAL/ideal_LunarImg_SCA_0p34577230_JD_2455864.7415237_illfrac_0.1608.fit", "../EARTHSHINE_CODE/OUTPUT/LONLAT_AND_ANGLES_IMAGES/lonlatSELimage_JD2455864.7415237.fits", "../EARTHSHINE_CODE/OUTPUT/LONLAT_AND_ANGLES_IMAGES/Angles_JD2455864.7415237.fits", "../EARTHSHINE_CODE/OUTPUT/SUNMASK/SunMask_JD_2455864.7415237.fit"]  # Modify these
output_directory = "OUTPUT/CUBES/"  # Change to the desired directory
output_filename = "fits_cube.fits"

# ---- Run the function ----
combine_fits_to_cube(fits_files, output_directory, output_filename)

