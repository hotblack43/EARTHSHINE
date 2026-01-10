import os
import numpy as np

#
# Generates synthetic moon image using the IDL code - should run this from EARTHSHINE_CODE ...
#

# Input parameters
jd_list_file = "all_MLO_observed_JD.dat"  # File containing list of JD values, one per line
output_directory = "OUTPUT/IDEAL"  # Directory to save outputs

# Configurable parameters
min_albedo = 0.1
max_albedo = 0.6  # Range for albedo values

# Create the output directory if it doesn't exist
os.makedirs(output_directory, exist_ok=True)

# Load the list of JD values from a file
with open(jd_list_file, "r") as f:
    jd_values = [float(line.strip()) for line in f.readlines()]

# Seed for reproducibility
np.random.seed(42)

# Loop over the JD values and generate images
for i, jd in enumerate(jd_values):
    # Generate a random albedo in the specified range
    albedo = np.random.uniform(min_albedo, max_albedo)

    # Print the current values (optional, for debugging)
#   print(f"JD: {jd:.7f}, Albedo: {albedo:.7f}")

    # Write JD to 'JDtouseforSYNTH'
    jd_file = 'JDtouseforSYNTH'
    with open(jd_file, "w") as f:
        f.write(f"{jd:.7f}\n")

    # Write albedo to 'single_scattering_albedo.dat' (in current working directory)
    albedo_file = 'single_scattering_albedo.dat'  # Write to current directory
    with open(albedo_file, "w") as f:
        f.write(f"{albedo:.7f}\n")

    # Run the external script (replace with the actual command)
    command = "gdl go_get_particular_synthimage_16_for_ML.pro"
    os.system(command)

print("Processing complete.")

