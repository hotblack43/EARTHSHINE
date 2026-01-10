import numpy as np
import tensorflow as tf
from tensorflow.keras import layers, models
import os


# Function to Resize Images
def preprocess_and_resize(images: np.ndarray, target_size: tuple) -> np.ndarray:
    """Resize images to a target size."""
    if len(images.shape) != 4:
        raise ValueError("Input images should have shape (batch, height, width, channels)")
    
    resized_images = []
    for img in images:
        resized_img = tf.image.resize(img, target_size, method='bilinear')  # Resize to target size
        resized_images.append(resized_img)
    
    return np.array(resized_images, dtype=np.float32)


# Build Flexible Generator
def build_generator():
    model = models.Sequential([
        layers.Input(shape=(None, None, 1)),  # Variable size grayscale input
        layers.Conv2D(64, kernel_size=7, padding="same"),
        layers.Activation("relu"),
        layers.Conv2D(1, kernel_size=7, padding="same")  # Reduce channels to 1
    ])
    return model


# Build Flexible Discriminator
def build_discriminator():
    model = models.Sequential([
        layers.Input(shape=(None, None, 1)),  # Variable size grayscale input
        layers.Conv2D(64, kernel_size=4, strides=2, padding="same"),
        layers.LeakyReLU(0.2),
    ])
    return model


# Initialize Models
generator_g = build_generator()
generator_f = build_generator()
discriminator_x = build_discriminator()
discriminator_y = build_discriminator()


# Initialize Models with Dummy Input
dummy_input = tf.random.normal([1, 128, 128, 1])  # Match your new image size
generator_g(dummy_input)
generator_f(dummy_input)
discriminator_x(dummy_input)
discriminator_y(dummy_input)


# Optimizers (Recreated After Model Initialization)
learning_rate = 0.0002
generator_optimizer = tf.keras.optimizers.Adam(learning_rate, beta_1=0.5)
discriminator_optimizer = tf.keras.optimizers.Adam(learning_rate, beta_1=0.5)


# Loss Functions
loss_obj = tf.keras.losses.BinaryCrossentropy(from_logits=False)


def discriminator_loss(real, generated):
    """Calculate discriminator loss."""
    real_loss = loss_obj(tf.ones_like(real), real)
    generated_loss = loss_obj(tf.zeros_like(generated), generated)
    return (real_loss + generated_loss) * 0.5


def generator_loss(generated):
    """Calculate generator loss."""
    return loss_obj(tf.ones_like(generated), generated)


# Training Step Function
@tf.function
def train_step(real_a, real_b, generator_g, generator_f, discriminator_x, discriminator_y, generator_optimizer, discriminator_optimizer):
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

    # Apply Gradients
    generator_optimizer.apply_gradients(zip(tape.gradient(total_gen_g_loss, generator_g.trainable_variables), generator_g.trainable_variables))
    generator_optimizer.apply_gradients(zip(tape.gradient(total_gen_f_loss, generator_f.trainable_variables), generator_f.trainable_variables))

    discriminator_optimizer.apply_gradients(zip(tape.gradient(disc_x_loss, discriminator_x.trainable_variables), discriminator_x.trainable_variables))
    discriminator_optimizer.apply_gradients(zip(tape.gradient(disc_y_loss, discriminator_y.trainable_variables), discriminator_y.trainable_variables))

    return total_gen_g_loss, disc_x_loss, disc_y_loss


# Load Preprocessed Data
real_a_images = np.load('/home/pth/SCALED_IMAGES/NumPy/DomainA_128x128.npy')
real_b_images = np.load('/home/pth/SCALED_IMAGES/NumPy/DomainB_128x128.npy')

real_a_images = np.expand_dims(real_a_images, axis=-1)
real_b_images = np.expand_dims(real_b_images, axis=-1)


# Create Dataset
batch_size = 1
dataset = tf.data.Dataset.from_tensor_slices((real_a_images, real_b_images))
dataset = dataset.shuffle(buffer_size=1000).batch(batch_size)


# Training Loop
epochs = 200
for epoch in range(epochs):
    print(f'Epoch: {epoch}')
    for real_a, real_b in dataset:
        loss_g, loss_d_x, loss_d_y = train_step(real_a, real_b, generator_g, generator_f, discriminator_x, discriminator_y, generator_optimizer, discriminator_optimizer)
    print(f"Epoch {epoch + 1}/{epochs}, Gen Loss: {loss_g:.4f}, Disc X Loss: {loss_d_x:.4f}, Disc Y Loss: {loss_d_y:.4f}")

