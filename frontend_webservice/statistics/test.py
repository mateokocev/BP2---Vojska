import matplotlib.pyplot as plt

# Generate some data to plot
x = [1, 2, 3, 4, 5]
y = [1, 4, 9, 16, 25]

# Create a figure with a specific size
plt.figure(figsize=(10,10))

# Plot the data
plt.plot(x, y)

# Save the figure as a 500x500 pixel image
plt.savefig('my_image.png', dpi=500)