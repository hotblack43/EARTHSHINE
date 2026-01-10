import sys
import random
import numpy as np
from astropy.io import fits
import cv2
from skimage import exposure, transform

def shift_image_lr_cyclic(image, shift):
    """
    Shift the image left or right by a specified number of columns with cyclic boundary conditions.

    Parameters:
        image (numpy.ndarray): Input image array.
        shift (int): Number of columns to shift. Positive for right shift, negative for left shift.

    Returns:
        numpy.ndarray: Shifted image array.
    """
    if shift == 0:
        return image.astype(np.float32)  # Ensure float32 data type if no shift is required

    # Convert to float32
    image = image.astype(np.float32)

    # Perform cyclic shift
    shifted_image = np.roll(image, shift, axis=1)

    return shifted_image


def shift_image_ud_cyclic(image, shift):
    """
    Shift the image up or down by a specified number of rows with cyclic boundary conditions.

    Parameters:
        image (numpy.ndarray): Input image array.
        shift (int): Number of rows to shift. Positive for down shift, negative for up shift.

    Returns:
        numpy.ndarray: Shifted image array.
    """
    if shift == 0:
        return image.astype(np.float32)  # Ensure float32 data type if no shift is required

    # Convert to float32
    image = image.astype(np.float32)

    # Perform cyclic shift
    shifted_image = np.roll(image, shift, axis=0)

    return shifted_image

# Read FITS image using Astropy
def read_fits_image(file_path):
    with fits.open(file_path) as hdul:
        image_data = hdul[0].data.astype(np.float32)  # Convert to float32
        header = hdul[0].header
    return image_data, header

# Save augmented image as FITS
def save_fits_image(image_data, input_header, output_path):
    hdu = fits.PrimaryHDU(image_data, header=input_header)
    hdul = fits.HDUList([hdu])
    hdul.writeto(output_path, overwrite=True)

# Augmentation functions
def rotate_image(image, angle):
# rotates an image by 'angle' in degrees
# mode can be
# 'reflect':  reflects pixel values at the edge, like a mirror.
# 'constant': Pads with a constant value (default cval=0)
# 'edge': Pads using the edge values
# 'wrap': Wraps around from the other side 
    return transform.rotate(image, angle, mode='reflect', preserve_range=True)

def scale_image(image, scale_factor):
    if scale_factor <= 0:
        return image  # Return the original image if scale factor is invalid

    # Calculate the center of the image
    center_x = image.shape[1] // 2
    center_y = image.shape[0] // 2

    # Calculate the new size after scaling
    new_width = int(image.shape[1] * scale_factor)
    new_height = int(image.shape[0] * scale_factor)

    # Calculate the coordinates of the top-left corner of the scaled image
    new_x = max(0, center_x - new_width // 2)
    new_y = max(0, center_y - new_height // 2)

    # Crop the image if it exceeds 512x512 after scaling
    cropped_image = image[new_y:new_y + new_height, new_x:new_x + new_width]

    # Pad the image with zeros if it's smaller than 512x512 after scaling
    padded_image = np.zeros((512, 512), dtype=image.dtype)
    padded_image[:cropped_image.shape[0], :cropped_image.shape[1]] = cropped_image

    return padded_image


def adjust_brightness(image, brightness_factor):
    return exposure.adjust_gamma(image, gamma=brightness_factor)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py <input_file>")
        sys.exit(1)

    input_file = sys.argv[1]
#   output_file = input_file.split('.')[0] + '_augmented.fits'
# Parse the filename to remove the extension and append '_augmented.fit'
    last_period_index = input_file.rfind('.')
    #output_file = input_file[:last_period_index] + '_augmented.fit'
    # Generate a random multidigit number (e.g., between 100 and 999)
    random_number = random.randint(100000, 999999)
# Construct the new output file with the random number
    output_file = input_file[:last_period_index] + f'_augmented_{random_number}.fit'
    print(input_file)
    print(output_file)

    # Read FITS image
    image_data, input_header = read_fits_image(input_file)
    augmented_image = image_data.astype(np.float32)  # Convert to float32

    # Augment image
    rnd_angle = random.random()*4.0-2.0 # Degrees, not radians
    rnd_scl = random.uniform(0.95, 1.05)
    augmented_image = rotate_image(augmented_image, angle=rnd_angle) # rotate by small angle in degrees
    x = random.random()
#   # Check if x falls within the specified ranges
#   if 0.25 < x < 0.5:
#       augmented_image = rotate_image(augmented_image, angle=90) # roatte by 90
#   elif 0.5 < x < 0.75:
#       augmented_image = rotate_image(augmented_image, angle=180) # roatte by 180
#   elif 0.75 < x < 1:
#       augmented_image = rotate_image(augmented_image, angle=270) # roatte by 270
    augmented_image = scale_image(augmented_image, scale_factor=rnd_scl)
    # shift lr and ud
    lr_shift=int(random.random()*60-30)
    ud_shift=int(random.random()*60-30)
    print(lr_shift,ud_shift)
    augmented_image = shift_image_lr_cyclic(augmented_image, lr_shift)
    augmented_image = shift_image_ud_cyclic(augmented_image, ud_shift)
    print("random angle:",rnd_angle)
    print("random scale:",rnd_scl)
    print("random lr shift:",lr_shift)
    print("random ud shift:",ud_shift)
    print("Size of augmented image:", augmented_image.shape)
    # Save augmented image
    save_fits_image(augmented_image, input_header, output_file)

