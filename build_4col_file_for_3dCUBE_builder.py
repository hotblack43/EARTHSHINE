import os

def read_julian_dates(file_path):
    """
    Reads a list of Julian Dates from a text file.
    
    Parameters:
        file_path (str): Path to the file containing Julian Dates.
    
    Returns:
        list of str: A list of Julian Date substrings.
    """
    with open(file_path, "r") as f:
        return [line.strip() for line in f if line.strip()]  # Remove empty lines


def find_files_by_julian_date(directory, julian_dates, output_file):
    """
    Searches for files in a directory that contain a given list of Julian Dates in their filenames.
    Ensures exactly 4 files per Julian Date and writes the output in 4-column format.

    Parameters:
        directory (str): The base directory where files are searched.
        julian_dates (list of str): List of Julian Date substrings to look for.
        output_file (str): Path to the output file where results will be saved.
    """
    results = []

    for jd in julian_dates:
        print(jd)
        matching_files = []

        # Walk through all subdirectories
        for root, _, files in os.walk(directory):
            for f in files:
                if jd in f and (f.endswith(".fit") or f.endswith(".fits")):  # Match JD and FITS extensions
                    matching_files.append(os.path.join(root, f))

        # ✅ Ensure exactly 4 matching files are found
        if len(matching_files) != 4:
            print(f"❌ Error: Found {len(matching_files)} files for Julian Date '{jd}', but expected 4.")
            print(f"Files found: {matching_files}")
            exit(1)

        # Sort the files alphabetically (to maintain order)
        matching_files.sort()
        results.append(matching_files)

    # ✅ Write to output file
    with open(output_file, "w") as f:
        for row in results:
            f.write("{:<100} {:<100} {:<100} {:<100}\n".format(*row))

    print(f"✅ Output saved to: {output_file}")


# ✅ Example Usage
directory = "./"  # 🔧 Change to your actual directory
julian_dates_file = "all_MLO_good_Moon_image_JDs.txt"  # 🔧 File containing Julian Dates (one per line)
output_file = "matched_files.txt"  # 🔧 Output file to store results

julian_dates = read_julian_dates(julian_dates_file)  # Read Julian Dates from file
find_files_by_julian_date(directory, julian_dates, output_file)  # Find files and save output

