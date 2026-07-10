# SaveSystem.gd
# Handles per-difficulty save/load for in-progress Sudoku games.
# Save path pattern: user://save_difficulty_{difficulty}.json

extends RefCounted

const SAVE_DIR = "user://"
const SAVE_PREFIX = "save_difficulty_"
const STREAKS_FILE = "user://streaks.json"

# Saves the current game state for a given difficulty.
# puzzle         : 2D array (9x9) — original puzzle with 0s for empty
# solution_grid  : 2D array (9x9) — full solution
# player_grid    : 2D array (9x9) — what the player has entered so far (0 if empty)
# notes_data     : Dictionary { "row_col": [1,3,5] } from NoteHandler
# lives          : int
# difficulty     : int (e.g. Settings.DIFFICULTY)
static func save_game(
	puzzle: Array,
	solution_grid: Array,
	player_grid: Array,
	notes_data: Dictionary,
	lives: int,
	difficulty: int
) -> void:
	var path = _get_path(difficulty)
	var data = {
		"difficulty": difficulty,
		"puzzle": puzzle,
		"solution_grid": solution_grid,
		"player_grid": player_grid,
		"notes_data": notes_data,
		"lives": lives,
		"timestamp": Time.get_unix_time_from_system()
	}
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()

# Loads saved game for a given difficulty.
# Returns a Dictionary with all saved fields, or {} if no save exists.
static func load_game(difficulty: int) -> Dictionary:
	var path = _get_path(difficulty)
	if not FileAccess.file_exists(path):
		return {}
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}
	var content = file.get_as_text()
	file.close()
	var result = JSON.parse_string(content)
	if result == null or not result is Dictionary:
		return {}
	return result

# Returns true if a save exists for this difficulty.
static func has_save(difficulty: int) -> bool:
	return FileAccess.file_exists(_get_path(difficulty))

# Deletes the save for a given difficulty (call on puzzle complete or new game).
static func delete_save(difficulty: int) -> void:
	var path = _get_path(difficulty)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

static func _get_path(difficulty: int) -> String:
	return SAVE_DIR + SAVE_PREFIX + str(difficulty) + ".json"
	
	
	
	
	
	
# --- STREAK SYSTEM ---

# loads the streak (json)
static func load_all_streaks() -> Dictionary:
	if not FileAccess.file_exists(STREAKS_FILE):
		return {}
		
	var file = FileAccess.open(STREAKS_FILE, FileAccess.READ)
	if not file:
		return {}
		
	var content = file.get_as_text()
	file.close()
	var result = JSON.parse_string(content)
	if result == null or not result is Dictionary:
		return {}
	return result

# Saves the full streak dictionary to file
static func _save_all_streaks(streaks_dict: Dictionary) -> void:
	
	var file = FileAccess.open(STREAKS_FILE, FileAccess.WRITE)
	
	if file == null:
		return
	
	file.store_string(JSON.stringify(streaks_dict))
	file.close()

# Streak based on difficulty
static func get_streak(difficulty: int) -> int:
	var streaks = load_all_streaks()
	var diff_key = str(difficulty) 
	return int(streaks.get(diff_key, 0))


static func increase_streak(difficulty: int) -> void:
	print("increase_streak CALLED")
	var streaks = load_all_streaks()
	var diff_key = str(difficulty)
	var current_streak = int(streaks.get(diff_key, 0))
	
	streaks[diff_key] = current_streak + 1
	_save_all_streaks(streaks)

# go back to 0
static func reset_streak(difficulty: int) -> void:
	var streaks = load_all_streaks()
	var diff_key = str(difficulty)
	
	streaks[diff_key] = 0
	_save_all_streaks(streaks)
