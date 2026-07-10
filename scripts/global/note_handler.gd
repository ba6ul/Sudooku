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

	if note_grid[row][col].is_empty():
		return ""
		
	var note_grid_text = [
		["", "", ""],
		["", "", ""],
		["", "", ""]
	]
	#plz work
	var note_positions = {
		1: [0, 0], 2: [0, 1], 3: [0, 2],
		4: [1, 0], 5: [1, 1], 6: [1, 2],
		7: [2, 0], 8: [2, 1], 9: [2, 2]
	}
	
	# pos
	var keys = note_grid[row][col].keys()
	keys.sort()
	for number in keys:
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
	
# Add these two methods to NoteHandler (autoload singleton)
# === Save System Integration Methods ===

# Returns all notes as a serializable dict: { "0_0": [1,3,5], "4_2": [9], ... }
func get_all_notes() -> Dictionary:
	var result = {}
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			if not note_grid[row][col].is_empty():
				var key = "%d_%d" % [row, col]
				result[key] = note_grid[row][col].keys()
	return result

# Restores notes for a cell from a loaded array (used by SaveSystem restore)
func set_notes(row: int, col: int, nums: Array) -> void:
	note_grid[row][col].clear()
	for num in nums:
		# Explicitly cast to int. JSON parsing often converts numbers to floats,
		# which would create keys like { 1.0: true } instead of { 1: true }
		note_grid[row][col][int(num)] = true
