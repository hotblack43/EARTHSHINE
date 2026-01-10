import os
from astropy.io import fits
import numpy as np
import tensorflow as tf
from typing import Tuple


def preprocess_existing_fits(
    domain_a_dir: str,
    domain_b_dir: str,
    output_dir: str,
    resize_shape: Tuple[int, int] = (128, 128)
):
    """
    Processes existing FITS images in DomainA and DomainB directories:
    scales pixel values to [-1, 1] and resizes them to a target size.

    Parameters:
        domain_a_dir (str): Path to DomainA FITS files (observed images).
        domain_b_dir (str): Path to DomainB FITS files (ideal images).
        output_dir (str): Directory to save preprocessed NumPy files.
        resize_shape (Tuple[int, int]): Target size for resizing images.
    """
    # Expand any tildes in the paths
    domain_a_dir = os.path.expanduser(domain_a_dir)
    domain_b_dir = os.path.expanduser(domain_b_dir)
    output_dir = os.path.expanduser(output_dir)

    os.makedirs(output_dir, exist_ok=True)

    size_suffix = f"{resize_shape[0]}x{resize_shape[1]}"

    # Process DomainA
    domain_a_processed = []
    for file in os.listdir(domain_a_dir):
        if file.endswith(".fits"):
            with fits.open(os.path.join(domain_a_dir, file)) as hdul:
                data = hdul[0].data.astype(np.float32)
                scaled_data = scale_image(data)
                resized_data = resize_image(scaled_data, resize_shape)
                domain_a_processed.append(resized_data)
    output_a = os.path.join(output_dir, f"DomainA_{size_suffix}.npy")
    np.save(output_a, np.array(domain_a_processed))
    print(f"Processed DomainA: {len(domain_a_processed)} images saved to {output_a}")

    # Process DomainB
    domain_b_processed = []
    for file in os.listdir(domain_b_dir):
        if file.endswith(".fits"):
            with fits.open(os.path.join(domain_b_dir, file)) as hdul:
                data = hdul[0].data.astype(np.float32)
                scaled_data = scale_image(data)
                resized_data = resize_image(scaled_data, resize_shape)
                domain_b_processed.append(resized_data)
    output_b = os.path.join(output_dir, f"DomainB_{size_suffix}.npy")
    np.save(output_b, np.array(domain_b_processed))
    print(f"Processed DomainB: {len(domain_b_processed)} images saved to {output_b}")


def scale_image(image: np.ndarray) -> np.ndarray:
    """Scales image pixel values to the range [-1, 1]."""
    min_pixel, max_pixel = np.min(image), np.max(image)
    return 2 * (image - min_pixel) / (max_pixel - min_pixel) - 1


def resize_image(image: np.ndarray, target_size: Tuple[int, int]) -> np.ndarray:
    """Resizes image to target dimensions using bilinear interpolation."""
    image = np.expand_dims(image, axis=-1)  # Add channel dimension for resizing
    resized = tf.image.resize(image, target_size, method='bilinear').numpy()
    return resized.squeeze()  # Remove the channel dimension


# Example Usage
preprocess_existing_fits(
    domain_a_dir="~/SCALED_IMAGES/CycleGAN/DomainA/",
    domain_b_dir="~/SCALED_IMAGES/CycleGAN/DomainB/",
    output_dir="~/SCALED_IMAGES/NumPy/",
    resize_shape=(128, 128)
)

