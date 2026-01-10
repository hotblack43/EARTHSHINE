import os
import datetime

subdirectory = "/app/OUTPUT/"
if not os.path.exists(subdirectory):
    os.makedirs(subdirectory)

filename = os.path.join(subdirectory, "example_file.txt")
now = datetime.datetime.now()
string_to_write = "Current date and time: " + now.strftime("%Y-%m-%d %H:%M:%S")

try:
    with open(filename, "w") as file:
        file.write(string_to_write)
        print("Successfully wrote to file:", filename)
except Exception as e:
    print("Error writing to file:", e)

