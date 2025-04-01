extends Node

const GRID_SIZE = 9

# 2D array for notes
var note_grid = []

func _ready():
	initialize_note_grid()

func initialize_note_grid():
	note_grid = []
	for _i in range(GRID_SIZE):
		var row = []
		for _j in range(GRID_SIZE):
			# cell empty
			row.append({})
		note_grid.append(row)

func add_note(row: int, col: int, number: int):
	# Note already exists, remove it
	if number in note_grid[row][col]:
		note_grid[row][col].erase(number)
	else:
		# Add the note
		note_grid[row][col][number] = true

func remove_note(row: int, col: int, number: int):
	# Remove single note
	note_grid[row][col].erase(number)

func get_formatted_note_text(row: int, col: int) -> String:
	# If no notes, return empty string
	if note_grid[row][col].is_empty():
		return ""
	
	# Create a 3x3 grid representation of notes with fixed spacing
	var note_grid_text = [
		["", "", ""],
		["", "", ""],
		["", "", ""]
	]
	
	# Map numbers to their positions in the 3x3 grid
	var note_positions = {
		1: [0, 0], 2: [0, 1], 3: [0, 2],
		4: [1, 0], 5: [1, 1], 6: [1, 2],
		7: [2, 0], 8: [2, 1], 9: [2, 2]
	}
	
	# Placing notes in their grid positions
	for number in note_grid[row][col].keys():
		var pos = note_positions[number]
		note_grid_text[pos[0]][pos[1]] = str(number)
	
	# Combining grid to string with fixed spacing
	var formatted_notes = ""
	for i in range(3):
		# Replace empty slots with spaces but maintain position
		var row_text = ""
		for j in range(3):
			if note_grid_text[i][j] == "":
				row_text += " "
			else:
				row_text += note_grid_text[i][j]
		formatted_notes += row_text + "\n"
	
	return formatted_notes.strip_edges()

func has_notes(row: int, col: int) -> bool:
	return not note_grid[row][col].is_empty()

func clear_notes(row: int, col: int):
	note_grid[row][col].clear()

func get_notes(row: int, col: int) -> Array:
	return note_grid[row][col].keys()
