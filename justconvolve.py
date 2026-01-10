# This code relies on the compile fortran code justconvolve_scwc.f
import os
import subprocess

def execute_binary(binary_path, input_filename, output_filename):
    # Prepare the command
    command = [binary_path]

    # Redirect input and output
    with open(input_filename, 'r') as input_file, open(output_filename, 'w') as output_file:
        # Execute the binary with input and output redirection
        process = subprocess.run(command, stdin=input_file, stdout=output_file, text=True)

        # Check if the process was successful
        if process.returncode == 0:
            print(f"Execution successful. Output saved to {output_filename}")
        else:
            print(f"Error during execution. Return code: {process.returncode}")

# Example usage
script_directory = os.path.dirname(os.path.realpath(__file__))  # Get the directory of the script
binary_path = '/home/pth/WORKSHOP/EARTHSHINE_CODE/justconvolve_scwc'
input_filename = '/home/pth/WORKSHOP/EARTHSHINE_CODE/OUTPUT/IDEAL/ideal_LunarImg_SCA_0p445_JD_2455867.2500000_illfrac_0.4042.fit'
output_filename = '/home/pth/WORKSHOP/EARTHSHINE_CODE/OUTPUT/IDEAL/AUGMENTED/FOLDED/ideal_LunarImg_SCA_0p445_JD_2455867.2500000_illfrac_0.4042.fit'
print('input : ',input_filename)
print('output: ',output_filename)
execute_binary(binary_path, input_filename, output_filename)

