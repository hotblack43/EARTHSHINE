import numpy as np
import tensorflow as tf
from tensorflow.keras import layers, models
import os

# Code to perform CycleGAN from Observed to Synethtic images (i.e. it makes Observed 
# images seem more synthetic so they could be used for an existing ML trained on synths only)
#
# Note that tensorflow/keras is being used - not Pytroch
#

# Enable GPU usage with TensorFlow in a conda environment
# Run: conda activate torch

# Build Generator
def build_generator():
    model = models.Sequential([
        layers.Input(shape=(512, 512, 1)),  # Expect grayscale input (1 channel)
        layers.Conv2D(64, kernel_size=7, padding="same"),
        layers.Activation("relu"),
        layers.Conv2D(1, kernel_size=7, padding="same")  # Reduce channels to 1
    ])
    return model

# Build Discriminator
def build_discriminator():
    model = models.Sequential([
        layers.Input(shape=(512, 512, 1)),  # Expect grayscale input (1 channel)
        layers.Conv2D(64, kernel_size=4, strides=2, padding="same"),
        layers.LeakyReLU(0.2),
    ])
    return model

# Initialize Models
generator_g = build_generator()
generator_f = build_generator()
discriminator_x = build_discriminator()
discriminator_y = build_discriminator()

# Display Model Summaries
generator_g.summary()
discriminator_x.summary()

# Define Optimizers
generator_optimizer = tf.keras.optimizers.Adam(learning_rate=0.0002, beta_1=0.5)
discriminator_optimizer = tf.keras.optimizers.Adam(learning_rate=0.0001, beta_1=0.5)

# Pre-build the optimizers with variables
all_generator_vars = generator_g.trainable_variables + generator_f.trainable_variables
all_discriminator_vars = discriminator_x.trainable_variables + discriminator_y.trainable_variables
generator_optimizer.build(all_generator_vars)
discriminator_optimizer.build(all_discriminator_vars)

# Define Loss Functions
loss_obj = tf.keras.losses.BinaryCrossentropy(from_logits=False)

def discriminator_loss(real, generated):
    real_loss = loss_obj(tf.ones_like(real), real)
    generated_loss = loss_obj(tf.zeros_like(generated), generated)
    return (real_loss + generated_loss) * 0.5

def generator_loss(generated):
    return loss_obj(tf.ones_like(generated), generated)

# Training Step Function
@tf.function
def train_step(real_a, real_b):
    with tf.GradientTape(persistent=True) as tape:
        fake_b = generator_g(real_a, training=True)
        fake_a = generator_f(real_b, training=True)

        cycle_a = generator_f(fake_b, training=True)
        cycle_b = generator_g(fake_a, training=True)

        disc_real_x = discriminator_x(real_b, training=True)
        disc_fake_x = discriminator_x(fake_b, training=True)

        disc_real_y = discriminator_y(real_a, training=True)
        disc_fake_y = discriminator_y(fake_a, training=True)

        # Generator Loss
        gen_g_loss = generator_loss(disc_fake_x)
        gen_f_loss = generator_loss(disc_fake_y)

        # Cycle-Consistency Loss
        cycle_loss = tf.reduce_mean(tf.abs(real_a - cycle_a)) + tf.reduce_mean(tf.abs(real_b - cycle_b))

        # Total Generator Loss
        total_gen_g_loss = gen_g_loss + cycle_loss
        total_gen_f_loss = gen_f_loss + cycle_loss

        # Discriminator Loss
        disc_x_loss = discriminator_loss(disc_real_x, disc_fake_x)
        disc_y_loss = discriminator_loss(disc_real_y, disc_fake_y)

    # Calculate Gradients
    generator_g_gradients = tape.gradient(total_gen_g_loss, generator_g.trainable_variables)
    generator_f_gradients = tape.gradient(total_gen_f_loss, generator_f.trainable_variables)

    discriminator_x_gradients = tape.gradient(disc_x_loss, discriminator_x.trainable_variables)
    discriminator_y_gradients = tape.gradient(disc_y_loss, discriminator_y.trainable_variables)

    # Apply Gradients
    generator_optimizer.apply_gradients(zip(generator_g_gradients, generator_g.trainable_variables))
    generator_optimizer.apply_gradients(zip(generator_f_gradients, generator_f.trainable_variables))

    discriminator_optimizer.apply_gradients(zip(discriminator_x_gradients, discriminator_x.trainable_variables))
    discriminator_optimizer.apply_gradients(zip(discriminator_y_gradients, discriminator_y.trainable_variables))

    return total_gen_g_loss, disc_x_loss, disc_y_loss

# Load Training Data
real_a_images = np.load('/home/pth/SCALED_IMAGES/NumPy/DomainA.npy') # Observed
real_b_images = np.load('/home/pth/SCALED_IMAGES/NumPy/DomainB.npy') # Synthetic

# Scramble Domain B to break pairing
real_b_images = np.random.permutation(real_b_images)

# Expand dimensions for grayscale channel
real_a_images = np.expand_dims(real_a_images, axis=-1)
real_b_images = np.expand_dims(real_b_images, axis=-1)
assert len(real_a_images) == len(real_b_images), "Datasets must have the same length!"

# Create Dataset
dataset_size = len(real_a_images)
dataset = tf.data.Dataset.from_tensor_slices((real_a_images, real_b_images))
dataset = dataset.shuffle(buffer_size=min(1000, dataset_size)).batch(batch_size=1)

# Training Loop
epochs = 200
for epoch in range(epochs):
    print(f"Epoch {epoch + 1}/{epochs}")
    for real_a, real_b in dataset:
        loss_g, loss_d_x, loss_d_y = train_step(real_a, real_b)
    print(f"Gen Loss: {loss_g.numpy():.4f}, Disc X Loss: {loss_d_x.numpy():.4f}, Disc Y Loss: {loss_d_y.numpy():.4f}")

# Save Models
save_dir = './saved_models'
os.makedirs(save_dir, exist_ok=True)
generator_g.save(os.path.join(save_dir, 'generator_g.keras'))
generator_f.save(os.path.join(save_dir, 'generator_f.keras'))
discriminator_x.save(os.path.join(save_dir, 'discriminator_x.keras'))
discriminator_y.save(os.path.join(save_dir, 'discriminator_y.keras'))

# Example of Recompiling Loaded Models
for model_name in ['generator_g', 'generator_f', 'discriminator_x', 'discriminator_y']:
    model_path = os.path.join(save_dir, f'{model_name}.keras')
    loaded_model = tf.keras.models.load_model(model_path)
    loaded_model.compile(optimizer=tf.keras.optimizers.Adam(0.0001, beta_1=0.5), loss='binary_crossentropy')
    print(f"{model_name} recompiled.")

