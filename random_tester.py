import random
import time

# Set seed based on current time
#random.seed(time.time())

# Generate a random float between 1.2 and 1.8
random_number = round(random.uniform(1.2, 1.8), 2)

# Print the random number
print("Random Number:", random_number)

