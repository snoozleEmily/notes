import tkinter as tk
from tkinter import messagebox, font, filedialog
from fpdf import FPDF


class TextInputApp:
    def __init__(self, master):
        self.master = master
        self.master.title("Text Input App")
        self.is_dark_mode = False  # Track the dark mode status
        root.geometry("500x350")  # Width x Height

        # Disable window resizing
        root.resizable(False, False)

        # Fonts
        title_font = font.Font(family="Helvetica", size=24, weight="bold")
        small_font = font.Font(family="Helvetica", size=8)

        # Title label
        self.title_label = tk.Label(
            master, text="NOTE SAVER", font=title_font, bg="light blue"
        )
        self.title_label.pack(pady=(10, 0))

        # Dictionary to store inputs
        self.inputs = {}
        self.current_id = 0
        self.selected_note_id = None

        # Input field
        self.input_field = tk.Entry(master)
        self.input_field.pack(pady=10)

        # Bind the Enter key to submit the input
        self.input_field.bind("<Return>", self.on_enter)

        # Submit button
        self.submit_button = tk.Button(master, text="Submit", command=self.submit_input)
        self.submit_button.pack(pady=5)

        # Display area for inputs (make it read-only)
        self.display_area = tk.Text(master, height=10, width=50, bg="white")
        self.display_area.pack(pady=10)
        self.display_area.config(state=tk.DISABLED)
        self.display_area.bind(
            "<Button-1>", self.select_note
        )  # Bind a click event to select notes

        # Frame for delete and save buttons
        self.delete_frame = tk.Frame(master, bg="light blue")
        self.delete_frame.pack(pady=5)

        # Delete button for a single note
        self.delete_button = tk.Button(
            self.delete_frame,
            text="Delete Selected Note",
            command=self.show_delete_confirmation,
        )
        self.delete_button.pack(side=tk.LEFT, padx=5)

        # Delete button for all notes
        self.delete_all_button = tk.Button(
            self.delete_frame,
            text="Delete All Notes",
            command=self.show_delete_all_confirmation,
        )
        self.delete_all_button.pack(side=tk.LEFT, padx=5)

        # Save button
        self.save_button = tk.Button(
            self.delete_frame,
            text="Save Notes",
            command=self.save_notes,
        )
        self.save_button.pack(side=tk.LEFT, padx=5)

        # Dark mode text label
        self.dark_mode_label = tk.Label(
            master, text="Dark Mode", font=small_font, bg="light blue"
        )
        self.dark_mode_label.place(x=425, y=0)

        # Dark mode toggle checkbox
        self.dark_mode_var = tk.IntVar()
        self.dark_mode_checkbox = tk.Checkbutton(
            master,
            variable=self.dark_mode_var,
            command=self.toggle_dark_mode,
            bg="light blue",
        )
        self.dark_mode_checkbox.place(x=440, y=14)

        # Set the initial theme to light mode
        self.set_light_mode()

    def submit_input(self):
        # Get the input text
        input_text = self.input_field.get()
        if input_text:  # Check if the input is not empty
            self.current_id += 1  # Increment the ID
            # Store the input in the dictionary
            self.inputs[self.current_id] = input_text

            # Clear the input field
            self.input_field.delete(0, tk.END)

            # Display the new value in the text area
            self.update_display_area()

    def on_enter(self, event):
        # Call the submit_input method when Enter is pressed
        self.submit_input()

    def update_display_area(self):
        # Clear and update the display area with current notes
        self.display_area.config(state=tk.NORMAL)
        self.display_area.delete(1.0, tk.END)
        for id, text in self.inputs.items():
            self.display_area.insert(tk.END, f"Note {id}: {text}\n")
        self.display_area.config(state=tk.DISABLED)

    def select_note(self, event):
        # Get the line number where the user clicked
        try:
            index = self.display_area.index(f"@{event.x},{event.y}")
            line_number = int(index.split(".")[0])
            # Extract the note text from that line
            line_text = self.display_area.get(f"{line_number}.0", f"{line_number}.end")

            # Identify the note ID from the line text
            if line_text.startswith("Note "):
                note_id = int(line_text.split(":")[0].split()[1])
                self.selected_note_id = note_id
                # Highlight the selected note (select and deselect other lines)
                self.highlight_selected_note()
        except Exception as e:
            print(f"Error selecting note: {e}")

    def highlight_selected_note(self):
        # Clear previous highlights
        self.display_area.tag_remove("selected", 1.0, tk.END)

        if self.selected_note_id:
            # Highlight the selected note in the text area with light blue color
            self.display_area.tag_config("selected", background="#ADD8E6")
            start_index = f"{self.selected_note_id}.0"
            end_index = f"{self.selected_note_id}.end"
            self.display_area.tag_add("selected", start_index, end_index)

    def show_delete_confirmation(self):
        if self.selected_note_id:
            # Get the text of the selected note
            selected_note_text = self.inputs[self.selected_note_id]

            # Confirmation message
            confirmation = messagebox.askyesno(
                "Confirm Deletion",
                f"Are you sure you want to delete Note {self.selected_note_id} - {selected_note_text}?",
            )
            if confirmation:
                self.delete_note()

    def delete_note(self):
        # Remove the note from inputs
        if self.selected_note_id in self.inputs:
            del self.inputs[self.selected_note_id]
            # Reassign note IDs to be sequential
            self.reassign_note_ids()
            # Clear the selected note
            self.selected_note_id = None
            # Update display
            self.update_display_area()

    def reassign_note_ids(self):
        # Reassign sequential IDs to the notes in the dictionary
        new_inputs = {}
        new_id = 1
        for old_id in sorted(self.inputs.keys()):
            new_inputs[new_id] = self.inputs[old_id]
            new_id += 1
        self.inputs = new_inputs
        self.current_id = new_id - 1  # Update current_id to the latest note's ID

    def show_delete_all_confirmation(self):
        # Confirmation message for deleting all notes
        confirmation = messagebox.askyesno(
            "Confirm Deletion",
            "Are you sure you want to delete ALL NOTES? All information will be lost.",
        )
        if confirmation:
            self.delete_all_notes()

    def delete_all_notes(self):
        # Clear all notes
        self.inputs.clear()  # Clear the dictionary
        self.selected_note_id = None
        self.current_id = 0  # Reset current_id
        self.update_display_area()  # Update the display area

    def toggle_dark_mode(self):
        # Toggle between light and dark mode based on the checkbox
        if self.dark_mode_var.get():
            self.set_dark_mode()
        else:
            self.set_light_mode()

    def set_light_mode(self):
        # Configure light mode colors
        self.master.configure(bg="light blue")
        self.title_label.config(bg="light blue", fg="#FF7F50")  # Pale red (coral) color
        self.input_field.config(bg="white", fg="black")
        self.display_area.config(bg="white", fg="black")
        self.delete_frame.config(bg="light blue")
        self.dark_mode_label.config(bg="light blue", fg="black")
        self.dark_mode_checkbox.config(bg="light blue", fg="black")
        self.is_dark_mode = False

    def set_dark_mode(self):
        # Configure dark mode colors
        self.master.configure(bg="gray15")
        self.title_label.config(bg="gray15", fg="white")
        self.input_field.config(bg="gray25", fg="white")
        self.display_area.config(bg="gray25", fg="white")
        self.delete_frame.config(bg="gray15")
        self.dark_mode_label.config(bg="gray15", fg="white")
        self.dark_mode_checkbox.config(bg="gray15", fg="white")
        self.is_dark_mode = True

    def save_notes(self):
        if not self.inputs:
            messagebox.showinfo("No Notes", "There are no notes to save.")
            return

        # Ask the user to select a file type (.txt or .pdf)
        file_path = filedialog.asksaveasfilename(
            defaultextension=".txt",
            filetypes=[
                ("Save as a TEXT file", "*.txt"),
                ("Save as a PDF file", "*.pdf"),
            ],
            title="Save Notes As",
            initialfile="myNotes",
        )

        # Check if the user canceled the file dialog
        if not file_path:
            return

        # Determine file extension and call the appropriate save method
        if file_path.endswith(".txt"):
            self.save_as_txt(file_path)
        elif file_path.endswith(".pdf"):
            self.save_as_pdf(file_path)

    def save_as_txt(self, file_path):
        # Save notes as a .txt file
        with open(file_path, "w") as file:
            for id, note in self.inputs.items():
                file.write(f"Note {id}: {note}\n")
        messagebox.showinfo("Saved", "Notes have been saved as a .txt file.")

    def save_as_pdf(self, file_path):
        # Save notes as a .pdf file
        pdf = FPDF()
        pdf.set_auto_page_break(auto=True, margin=15)
        pdf.add_page()
        pdf.set_font("Arial", size=12)
        for id, note in self.inputs.items():
            pdf.cell(200, 10, txt=f"Note {id}: {note}", ln=True)
        pdf.output(file_path)
        messagebox.showinfo("Saved", "Notes have been saved as a .pdf file.")


if __name__ == "__main__":
    root = tk.Tk()
    app = TextInputApp(root)
    root.mainloop()
