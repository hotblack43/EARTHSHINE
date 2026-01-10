import numpy as np
import matplotlib.pyplot as plt

# Create a circular lunar disk
fig, ax = plt.subplots(figsize=(6,6))
circle = plt.Circle((0, 0), 1, color='gray', alpha=0.3)
ax.add_patch(circle)

# Define regions for DS Fan and BS Fan
theta_ds = np.linspace(-30, 30, 100)  # Dark Side Fan (degrees)
theta_bs = np.linspace(150, 210, 100) # Bright Side Fan

# Convert to Cartesian coordinates
def polar_to_cartesian(r, theta_deg):
    theta = np.radians(theta_deg)
    return r * np.cos(theta), r * np.sin(theta)

# Plot DS Fan
x_ds, y_ds = polar_to_cartesian(1.1, theta_ds)
ax.fill_betweenx(y_ds, -1.2, x_ds, color='red', alpha=0.4, label="DS Fan (Fitting Region)")

# Plot BS Fan
x_bs, y_bs = polar_to_cartesian(1.1, theta_bs)
ax.fill_betweenx(y_bs, x_bs, 1.2, color='blue', alpha=0.4, label="BS Fan (Scattering Correction)")

# Labels
ax.set_xlim(-1.3, 1.3)
ax.set_ylim(-1.3, 1.3)
ax.set_xticks([])
ax.set_yticks([])
ax.set_title("Lunar Image Fitting Regions")
ax.legend()

plt.show()

