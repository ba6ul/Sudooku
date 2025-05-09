class_name HintSystem
extends Object


const MAX_HINTS = 5
const HINT_COST = 10  #future scoring system
const HINT_COLORS = {
	"default": Color.DARK_GOLDENROD, 
	"partial": Color("#FFA500"), 
	"full": Color.DARK_GREEN    
}

# stats
var hint_counter: int = 0
var hint_strategy: int = 2  # hin version selector

# Hint versions
enum HintMode {
	random_cell,    # Fills a random empty cell
	hardest_cell, # Premium Hint
	strategic       # Advanced hint selection
}

# Hint information structure
class HintInfo:
	var row: int
	var col: int
	var correct_number: int
	var hint_type: String
	
	func _init(r: int, c: int, number: int, type: String = "default"):
		row = r
		col = c
		correct_number = number
		hint_type = type


func generate_hint(puzzle: Array, solution_grid: Array) -> HintInfo:
	# Verify
	if hint_counter >= MAX_HINTS:
		return null
	
	var empty_cells = _find_empty_cells(puzzle)
	
	if empty_cells.is_empty():
		return null
	
	# Select hint based on hint version
	var hint_cell = _select_hint_cell(empty_cells, puzzle, solution_grid)
	
	var hint = HintInfo.new(
		hint_cell.x, 
		hint_cell.y, 
		solution_grid[hint_cell.x][hint_cell.y]
	)
	
	hint_counter += 1
	return hint

func _find_empty_cells(puzzle: Array) -> Array:
	var empty_cells = []
	for row in range(puzzle.size()):
		for col in range(puzzle[row].size()):
			if puzzle[row][col] == 0:
				empty_cells.append(Vector2(row, col))
	return empty_cells

# Select hint cell for hint version
func _select_hint_cell(empty_cells: Array, puzzle: Array, solution_grid: Array) -> Vector2:
	match hint_strategy:
		HintMode.random_cell:
			return empty_cells[randi() % empty_cells.size()]
		
		HintMode.hardest_cell:
			return _find_most_constrained_cell(empty_cells, puzzle)
		
		HintMode.strategic:
			return _strategic_hint_selection(empty_cells, puzzle, solution_grid)
		
		_:  
			return empty_cells[randi() % empty_cells.size()]


func _find_most_constrained_cell(empty_cells: Array, puzzle: Array) -> Vector2:
	var most_constrained = empty_cells[0]
	var least_options = 9
	
	for cell in empty_cells:
		var row = cell.x
		var col = cell.y
		var options = _count_valid_options(puzzle, row, col)
		
		if options < least_options:
			least_options = options
			most_constrained = cell
	
	return most_constrained

func _count_valid_options(puzzle: Array, row: int, col: int) -> int:
	var options = 0
	for num in range(1, 10):
		if _is_valid_entry(puzzle, row, col, num):
			options += 1
	return options

# Valid check for hardest cell
func _is_valid_entry(puzzle: Array, row: int, col: int, num: int) -> bool:
	#sudoku validation logic
	return true  # Placeholder - implement full validation

# Gives hint for selected cell
func _strategic_hint_selection(empty_cells: Array, puzzle: Array, solution_grid: Array) -> Vector2:
	# idk
	return empty_cells[randi() % empty_cells.size()]

# for new game
func reset():
	hint_counter = 0
	hint_strategy = HintMode.random_cell

# checks hint version
func get_hint_status() -> Dictionary:
	return {
		"hints_used": hint_counter,
		"hints_remaining": MAX_HINTS - hint_counter,
		"current_strategy": hint_strategy
	}

# fordev hint version
func set_hint_strategy(strategy: int):
	hint_strategy = strategy
