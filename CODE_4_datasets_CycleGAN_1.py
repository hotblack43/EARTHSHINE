import numpy as np
import torch
from torch.utils.data import Dataset

#
# defines a custom PyTorch dataset class (NumpyDataset) to handle loading and preprocessing of image data stored in NumPy arrays.
#

class NumpyDataset(Dataset):
    def __init__(self, domain_a_path, domain_b_path, transform=None):
        self.domain_a = np.load(domain_a_path)  # Load observed images
        self.domain_b = np.load(domain_b_path)  # Load ideal images
        self.transform = transform

    def __len__(self):
        return min(len(self.domain_a), len(self.domain_b))  # Ensure paired data

    def __getitem__(self, idx):
        img_a = self.domain_a[idx]
        img_b = self.domain_b[idx]

        # Add channel dimension for PyTorch (1, H, W)
        img_a = np.expand_dims(img_a, axis=0)
        img_b = np.expand_dims(img_b, axis=0)

        if self.transform:
            img_a = self.transform(img_a)
            img_b = self.transform(img_b)

        return torch.tensor(img_a, dtype=torch.float32), torch.tensor(img_b, dtype=torch.float32)

