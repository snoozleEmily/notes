import PySimpleGUI as sg
import tkinter as tk

# --- Function to redraw everything when undo/redo occurs ---
def redraw_all():
    graph.TKCanvas.delete("all")
    for stroke in strokes:
        for segment in stroke:
            start, end, color, width = segment
            graph.draw_line(start, end, color=color, width=width)
    draw_color_circles()  # Re-draw color circles after clearing canvas

# --- Function to draw circular color options ---
def draw_color_circles():
    radius = 15
    y_pos = 20  # Fixed Y position for all color circles
    x_spacing = 40  # Spacing between colors
    x_start = 50  # Starting position for first color
    color_positions.clear()
    
    for i, color in enumerate(palette_colors):
        x = x_start + i * x_spacing
        graph.draw_circle((x, y_pos), radius, fill_color=color, line_color='black')
        color_positions.append((x, y_pos, color))  # Store position and color

# --- Initialize PySimpleGUI layout ---
palette_colors = ['black', 'red', 'green', 'blue', 'orange', 'purple']
color_positions = []  # Stores the (x, y, color) of each circle

layout = [
    [sg.Button("Erase All"), sg.Button("Undo"), sg.Button("Redo")],
    [sg.Graph(canvas_size=(640, 480),
              graph_bottom_left=(0, 480),
              graph_top_right=(640, 0),
              background_color='white',
              key='graph',
              enable_events=True,
              drag_submits=True)]
]

# Create the window
window = sg.Window("Improved Paint App", layout, finalize=True)
graph = window['graph']

# Change the cursor to a pencil-like shape
canvas_widget = graph.Widget
canvas_widget.configure(cursor="pencil")

# Draw color circles
draw_color_circles()

# Variables for drawing and managing strokes
current_color = 'black'
strokes = []          # List of completed strokes (each stroke is a list of segments)
redo_strokes = []     # Stack of undone strokes
current_stroke = None # Stroke currently being drawn (list of segments)
prev_point = None     # Previous point in the current stroke

while True:
    event, values = window.read()

    # Finalize stroke if interacting with UI
    if event != 'graph' and current_stroke:
        if len(current_stroke) > 0:
            strokes.append(current_stroke)
            redo_strokes.clear()  # Clear redo history after a new stroke
        current_stroke = None
        prev_point = None

    # Exit program
    if event == sg.WIN_CLOSED:
        break

    # Handle drawing
    if event == 'graph':
        x, y = values['graph']

        # Check if user clicked on a color circle
        for cx, cy, color in color_positions:
            if ((x - cx) ** 2 + (y - cy) ** 2) ** 0.5 <= 15:  # Check if inside circle
                current_color = color
                break
        else:
            # Start new stroke if not on a color circle
            if prev_point is None:
                current_stroke = []
                prev_point = (x, y)
            else:
                segment = (prev_point, (x, y), current_color, 2)
                graph.draw_line(prev_point, (x, y), color=current_color, width=2)
                current_stroke.append(segment)
                prev_point = (x, y)

    # Handle Erase All button
    elif event == "Erase All":
        strokes.clear()
        redo_strokes.clear()
        current_stroke = None
        prev_point = None
        graph.TKCanvas.delete("all")
        draw_color_circles()  # Re-draw the color selection circles

    # Handle Undo
    elif event == "Undo":
        if strokes:
            redo_strokes.append(strokes.pop())
            redraw_all()

    # Handle Redo
    elif event == "Redo":
        if redo_strokes:
            strokes.append(redo_strokes.pop())
            redraw_all()

window.close()
