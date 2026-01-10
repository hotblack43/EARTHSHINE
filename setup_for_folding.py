import os
import sys
import random

def modify_paths(original_path):
    modified_path = original_path.replace("AUGMENTED", "AUGMENTED/FOLDED")
    modified_path = modified_path.rsplit('/', 1)[0] + "/folded_" + modified_path.rsplit('/', 1)[-1]
    return modified_path

#def generate_command(original_path, modified_path):
#    return f"./justconvolve_scwc '{original_path}' '{modified_path}' 1.8 2.0 9"

def generate_command(original_path, modified_path):
    random_factor = round(random.uniform(1.2, 1.8), 2)
    return f"./justconvolve_scwc '{original_path}' '{modified_path}' {random_factor} 2.0 9"


def main(directory_path):
    for filename in os.listdir(directory_path):
        if filename.endswith(".fit"):
            original_path = os.path.join(directory_path, filename)
            modified_path = modify_paths(original_path)
            command = generate_command(original_path, modified_path)
            print(command)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python setup_for_folding.py <directory_path>")
        sys.exit(1)

    user_directory = sys.argv[1]
    main(user_directory)

