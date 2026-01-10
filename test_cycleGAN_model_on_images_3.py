import os
import numpy as np
import tensorflow as tf
from tensorflow.keras.models import load_model
from astropy.io import fits
from datetime import datetime

# Paths to the saved models
generator_g_path = '/home/pth/SCALED_IMAGES/CycleGAN/saved_models/generator_g.keras'
generator_f_path = '/home/pth/SCALED_IMAGES/CycleGAN/saved_models/generator_f.keras'

# Load the saved generators
generator_g = load_model(generator_g_path)
generator_f = load_model(generator_f_path)

# Function to load and preprocess FITS images
def preprocess_fits(image_path, target_size=(512, 512)):
    with fits.open(image_path) as hdul:
        img_data = hdul[0].data
    if img_data is None:
        raise ValueError(f"No data found in FITS file: {image_path}")

    # Ensure the image is 2D
    if img_data.ndim != 2:
        raise ValueError(f"Image from {image_path} must be 2D but has shape {img_data.shape}")

    # Normalize the image to [-1, 1]
    img_data = img_data.astype(np.float32)
    img_min, img_max = np.min(img_data), np.max(img_data)
    img_data = 2 * ((img_data - img_min) / (img_max - img_min + 1e-6)) - 1  # Scale to [-1, 1]

    # Resize and expand dimensions to add channel and batch axes
    img_resized = tf.image.resize(img_data[..., np.newaxis], target_size).numpy()
    img_array = np.expand_dims(img_resized, axis=0)  # Add batch dimension
    return img_array

# Function to save output as 16-bit FITS
def save_fits(output_array, save_path):
    # Rescale from [-1, 1] to [0, 65535]
    output_array = ((output_array[0, :, :, 0] + 1) / 2.0 * 65535).astype(np.uint16)
    hdu = fits.PrimaryHDU(output_array)
    hdu.writeto(save_path, overwrite=True)
    print(f"Saved FITS file to: {save_path}")

# Testing function
def test_model(input_fits_path, generator, output_fits_path):
    input_image = preprocess_fits(input_fits_path)
    generated_image = generator(input_image, training=False)
    save_fits(generated_image.numpy(), output_fits_path)

# Hardcoded test input images and output paths
test_images = [
    '/home/pth/SCALED_IMAGES/CycleGAN/DomainA/2455865.7600977OBSERVED_SCALED.fits', 
    '/home/pth/SCALED_IMAGES/CycleGAN/DomainB/2455865.7600977IDEAL.fits'
]
output_dir = '/home/pth/SCALED_IMAGES/test_results/'

# Ensure the output directory exists
os.makedirs(output_dir, exist_ok=True)

# Test the models
for i, test_image in enumerate(test_images):
    # Use timestamp and index to generate unique filenames
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    base_name = os.path.basename(test_image).split('.')[0]
    output_path_g = f"{output_dir}output_g_{base_name}_{timestamp}_{i}.fits"
    output_path_f = f"{output_dir}output_f_{base_name}_{timestamp}_{i}.fits"
    
    # Test generator_g
    test_model(test_image, generator_g, output_path_g)
    
    # Test generator_f
    test_model(test_image, generator_f, output_path_f)

