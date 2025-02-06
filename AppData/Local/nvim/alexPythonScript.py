import random
import tkinter as tk

import numpy as np

# Initialize neural network parameters
input_size = 4
hidden_size = 5
output_size = 4
learning_rate = 0.01

# Initialize weights
weights_input_hidden = np.random.randn(input_size, hidden_size)
weights_hidden_output = np.random.randn(hidden_size, output_size)

# Initialize previous button pressed
last_button = None

# Mapping from button text to indices
button_to_index = {"Knopf 1": 0, "Knopf 2": 1, "Knopf 3": 2, "Knopf 4": 3}
index_to_button = {0: "Knopf 1", 1: "Knopf 2", 2: "Knopf 3", 3: "Knopf 4"}


def softmax(x):
    e_x = np.exp(x - np.max(x))
    return e_x / e_x.sum()


def predict(input_data):
    hidden_layer_input = np.dot(input_data, weights_input_hidden)
    hidden_layer_output = np.tanh(hidden_layer_input)
    output_layer_input = np.dot(hidden_layer_output, weights_hidden_output)
    output = softmax(output_layer_input)
    return output


def train(input_data, target_data):
    global weights_input_hidden, weights_hidden_output
    hidden_layer_input = np.dot(input_data, weights_input_hidden)
    hidden_layer_output = np.tanh(hidden_layer_input)
    output_layer_input = np.dot(hidden_layer_output, weights_hidden_output)
    output = softmax(output_layer_input)

    # Calculate error
    error = target_data - output

    # Backpropagation
    d_output = error
    d_hidden = d_output.dot(weights_hidden_output.T) * (
        1 - np.tanh(hidden_layer_input) ** 2
    )

    # Reshape inputs for matrix multiplication
    hidden_layer_output = hidden_layer_output.reshape(-1, 1)
    input_data = input_data.reshape(-1, 1)

    # Update weights
    weights_hidden_output += (
        hidden_layer_output.dot(d_output.reshape(1, -1)) * learning_rate
    )
    weights_input_hidden += input_data.dot(d_hidden.reshape(1, -1)) * learning_rate


def update_model(button_pressed):
    global last_button
    if last_button is not None:
        input_data = np.zeros(input_size)
        input_data[button_to_index[last_button]] = 1

        target_data = np.zeros(output_size)
        target_data[button_to_index[button_pressed]] = 1

        train(input_data, target_data)

    last_button = button_pressed


def change_colors(button_pressed):
    update_model(button_pressed)
    colors = ["red", "blue", "green", "yellow", "purple", "orange"]
    new_colors = random.sample(colors, 4)

    red_button.config(bg=new_colors[0])
    blue_button.config(bg=new_colors[1])
    green_button.config(bg=new_colors[2])
    yellow_button.config(bg=new_colors[3])

    input_data = np.zeros(input_size)
    input_data[button_to_index[button_pressed]] = 1

    predictions = predict(input_data)
    predicted_index = np.argmax(predictions)
    predicted_button = index_to_button[predicted_index]

    print(f"Predicted next button: {predicted_button}")


def on_red_button_click():
    change_colors("Knopf 1")


def on_blue_button_click():
    change_colors("Knopf 2")


def on_green_button_click():
    change_colors("Knopf 3")


def on_yellow_button_click():
    change_colors("Knopf 4")


# Hauptfenster erstellen
root = tk.Tk()
root.title("Farbwechselnde Knöpfe mit Vorhersage")

# Größe des Fensters festlegen
root.geometry("400x400")

# Roter Knopf erstellen
red_button = tk.Button(
    root,
    text="Knopf 1",
    command=on_red_button_click,
    bg="red",
    fg="white",
    width=10,
    height=5,
)
red_button.grid(row=0, column=0, padx=10, pady=10)

# Blauer Knopf erstellen
blue_button = tk.Button(
    root,
    text="Knopf 2",
    command=on_blue_button_click,
    bg="blue",
    fg="white",
    width=10,
    height=5,
)
blue_button.grid(row=0, column=1, padx=10, pady=10)

# Grüner Knopf erstellen
green_button = tk.Button(
    root,
    text="Knopf 3",
    command=on_green_button_click,
    bg="green",
    fg="white",
    width=10,
    height=5,
)
green_button.grid(row=1, column=0, padx=10, pady=10)

# Gelber Knopf erstellen
yellow_button = tk.Button(
    root,
    text="Knopf 4",
    command=on_yellow_button_click,
    bg="yellow",
    fg="black",
    width=10,
    height=5,
)
yellow_button.grid(row=1, column=1, padx=10, pady=10)

# Hauptschleife starten
root.mainloop()
