import math
import numpy as np
import matplotlib.pyplot as plt
import tifffile

# --- Load LRO Albedo Data ---
def get_lro_albedo():
    im = tifffile.imread('Eshine/1x1_70NS_7b_wbhs_albflt_grid_geirist_tcorrect_w.tif')
    print("Raw LRO shape:", im.shape)  # diagnostic
    return im

# --- Visualize LRO Bands ---
def show_lro_bands(lro_cube):
    n_bands = lro_cube.shape[0]
    fig, axes = plt.subplots(1, n_bands, figsize=(3*n_bands, 4))
    for i in range(n_bands):
        ax = axes[i]
        ax.imshow(lro_cube[i], cmap='gray', origin='lower')
        ax.set_title(f'LRO Band {i}')
        ax.axis('off')
    plt.tight_layout()
    plt.show()

# --- Run diagnostics ---
if __name__ == '__main__':
    lro_data = get_lro_albedo()
    show_lro_bands(lro_data)

