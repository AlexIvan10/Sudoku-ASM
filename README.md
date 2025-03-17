# Sudoku in Assembly

This is a Sudoku game project implemented in Assembly, using the canvas.lib library for graphical interface. The game allows simple interactions with the Sudoku board through mouse clicks.

## Table of Contents
- **Features**
- **Project Structure**
- **Notes**

---

## Features

- **Number Incrementing**: Clicking on a cell increments the number sequentially.
- **Automatic Validation**: If a number already exists in the same row or column, the game automatically skips it.
- **Cell Reset**: After reaching the number 9, the next click will make the cell blank.
- **Reset Button**: Resets the board to its initial state.

---

## Project Structure

- **Source Code**: Implemented in Assembly, using macros to handle drawing and number validation.
- **Validity Check**: Automatically performed with each increment, ensuring that the basic Sudoku rules are not violated.
- **Graphical Display**: Uses the make_button and make_text_macro macros to generate the graphical interface and display numbers.

---

## Notes

- The code includes a predefined board that can be modified in the .data section.
- Number validation is performed automatically with each click, providing immediate visual feedback.
