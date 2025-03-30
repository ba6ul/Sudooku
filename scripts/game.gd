extends Node2D

@onready var grid:GridContainer = $GridContainer
@onready var button: Button = $Button
@onready var lives_label: Label = $Label
@onready var hint_button: Button = $HintButton

var hint_system = HintSystem.new()

var lives = 3

# Game Grid
var game_grid = [] # Holds the buttons present in the Game Scene
var puzzle = [] # Holds the puzzle
var solution_grid = [] # Holds the answer to the puzzle
var solution_count = 0 # No. of valid solution to a solution grid, used only for generating valid grid

var selected_button:Vector2i = Vector2(-1, -1)
var select_button_answer = 0

const GRID_SIZE = 9

# Colors for the Cells 
const highlight_rang = Color("#362D5E") # Light blue
const subgrid_highlight_rang = Color("#362D5E") # Light blue (just for testing)

# Called when the node enters the scene tree for the first time.
func _ready():
	bind_selectgrid_button_actions()
	init_game()
	
	var hint_status = hint_system.get_hint_status()
	hint_button.text = "Hint: " + str(hint_status["hints_remaining"])
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	lives_update()

func init_game():
	
	_create_empty_grid()
	_fill_grid(solution_grid) # We will get the solution grid
	_create_puzzle(Settings.DIFFICULTY)
	
	_populate_grid()
	

func _populate_grid():
	game_grid = []
	for i in range(GRID_SIZE):
		var row = []
		for j in range(GRID_SIZE):
			row.append(create_button(Vector2(i, j)))
		game_grid.append(row)

func create_button(pos:Vector2i):
	var row = pos[0]
	var col = pos[1]
	var ans = solution_grid[row][col]
	
	var button = Button.new()
	if puzzle[row][col] != 0:
		button.text = str(puzzle[row][col])
	button.set("theme_override_font_sizes/font_size", 32)
	
	#V2
	var stylebox:StyleBoxFlat = button.get_theme_stylebox("normal").duplicate(true)
	stylebox.bg_color = Settings.Cell_rang
	button.add_theme_stylebox_override("normal", stylebox)
	
	#v3 Adds gap
	var gap_size = 6
	var gap_Container = MarginContainer.new()
	
	if row > 0 and row % 3 == 0:
		gap_Container.add_theme_constant_override("margin_top", gap_size)
	
	if col > 0 and col % 3 == 0:
		gap_Container.add_theme_constant_override("margin_left", gap_size)
	gap_Container.add_child(button)
	
	button.custom_minimum_size = Vector2(52, 52)
	button.pressed.connect(_on_grid_button_pressed.bind(pos, ans))
	grid.add_child(gap_Container)
	return button

# v4 Highlight
func highlight_related_cells(pos: Vector2i):
	reset_cell_colors()

	var row = pos[0]
	var col = pos[1]

	# Subgrid
	var subgrid_row_start = (row / 3) * 3
	var subgrid_col_start = (col / 3) * 3

	# Loops and Checks row, col, subgrid
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			var btn = game_grid[i][j] as Button
			var stylebox = btn.get_theme_stylebox("normal").duplicate(true)

			var current_bg_color = stylebox.bg_color

			if i == row and j == col:
				#To highlight the selected cell, add a condition here like:
				# if current_bg_color != Color.SEA_GREEN and current_bg_color != Color.DARK_RED:
				#     stylebox.bg_color = highlight_rang
				pass #
			elif i == row or j == col:
				# Highlight ROW and COL (except red and green cell)
				if current_bg_color != Color.SEA_GREEN and current_bg_color != Color.DARK_RED:
					stylebox.bg_color = highlight_rang
			elif (i >= subgrid_row_start and i < subgrid_row_start + 3 and
				  j >= subgrid_col_start and j < subgrid_col_start + 3):
				# Highlight subgrid (except red and green cell)
				if current_bg_color != Color.SEA_GREEN and current_bg_color != Color.DARK_RED:
					stylebox.bg_color = subgrid_highlight_rang

			btn.add_theme_stylebox_override("normal", stylebox)
# Change back color
func reset_cell_colors():
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			var btn = game_grid[i][j] as Button
			var stylebox = btn.get_theme_stylebox("normal").duplicate(true)
			
			# Changing back Colors
			if not (Settings.SHOW_HINTS and btn.text != "" and 
				   ((int(btn.text) == solution_grid[i][j] and stylebox.bg_color == Color.SEA_GREEN) or
					(int(btn.text) != solution_grid[i][j] and stylebox.bg_color == Color.DARK_RED))):
				stylebox.bg_color = Settings.Cell_rang
				
			btn.add_theme_stylebox_override("normal", stylebox)

func _on_grid_button_pressed(pos: Vector2i, ans):
	selected_button = pos
	select_button_answer = ans
	highlight_related_cells(pos)
	
	var grid_selected_button = game_grid[selected_button[0]][selected_button[1]]
	
	if grid_selected_button.text != "" and puzzle[selected_button[0]][selected_button[1]] != 0:
		for button in $SelectGrid.get_children():
			button.disabled = true
	else:
		for button in $SelectGrid.get_children():
			button.disabled = false

func bind_selectgrid_button_actions():
	for button in $SelectGrid.get_children():
		var b = button as Button
		b.pressed.connect(_on_selectgrid_button_pressed.bind(int(b.text)))

func _on_selectgrid_button_pressed(number_pressed):
	if selected_button != Vector2i(-1, -1):
		var grid_selected_button = game_grid[selected_button[0]][selected_button[1]]
		grid_selected_button.text = str(number_pressed)

		# To make it easy for beginners, we could provide hints to show whether their answer is right or wrong.
		if Settings.SHOW_HINTS:
			var result_match = (number_pressed == select_button_answer)
			
			var btn = game_grid[selected_button[0]][selected_button[1]] as Button
			
			var stylebox:StyleBoxFlat = btn.get_theme_stylebox("normal").duplicate(true)
			if result_match == true:
				stylebox.bg_color = Color.SEA_GREEN
			else:
				stylebox.bg_color = Color.DARK_RED
				lives -= 1
				
			if lives == 0:
				get_tree().reload_current_scene()
			btn.add_theme_stylebox_override("normal", stylebox)
			
		# Make sure to highlight the cell back after new Input
		highlight_related_cells(selected_button)

func lives_update():
	lives_label.text = "Lives left " + str(lives)

# Generating Valid Sudoku grid
# Recursively validate a position entry and generates a solution grid
func _fill_grid(grid_obj):
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if grid_obj[i][j] == 0:
				var numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9]
				numbers.shuffle()
				for num in numbers:
					if is_valid(grid_obj, i, j, num):
						grid_obj[i][j] = num
						if _fill_grid(grid_obj):
							return true
						grid_obj[i][j] = 0
				return false
	return true
			
func _create_empty_grid():
	# Start with an empty solution grid where all cells have 0 entry
	solution_grid = []
	for i in range(GRID_SIZE):
		var row = []
		for j in range(GRID_SIZE):
			row.append(0)
		solution_grid.append(row)

func is_valid(grd, row, col, num):
	# Checks whether the given entry for a number (num)
	# in the grid's [row, col] location is a valid entry.
	# Uses standard Sudoku rules:
	# The numbers from 1-9 should be present in:
	#    1. Row
	#    2. Column
	#    3. Subgrid (3x3)
	return (
		num not in grd[row] and 
		num not in get_column(grd, col) and 
		num not in get_subgrid(grd, row, col)
	)

func get_column(grd, col):
	var col_list = []
	for i in range(GRID_SIZE):
		col_list.append(grd[i][col])
	return col_list

func get_subgrid(grd, row, col):
	var subgrid = []
	var start_row = (row / 3) * 3
	var start_col = (col / 3) * 3
	for r in range(start_row, start_row + 3):
		for c in range(start_col, start_col + 3):
			subgrid.append(grd[r][c])
	return subgrid

# Remove values from the solution grid 
# Inorder to create puzzle from the given solution grid,
# start removing some entries in the cell.
# The difficulty control how many cells have to be removed.
func _create_puzzle(difficulty):
	puzzle = solution_grid.duplicate(true)
	var removals = difficulty * 10 # Example Easy = 20, Hard = 50
	while removals > 0:
		var row = randi_range(0, 8)
		var col = randi_range(0, 8)
		if puzzle[row][col] != 0:
			var temp = puzzle[row][col]
			puzzle[row][col] = 0
			# While removing the cell, we need to ensure that the
			# solution present would still lead to a unique solution.
			# This can be time consuming and ideally have to use some optimization trick to speed up
			# But that's for some other time.
			if not has_unique_solution(puzzle):
				puzzle[row][col] = temp
			else:
				removals -= 1

func has_unique_solution(puzzle_grid):
	# Checks whether the given grid puzzle will lead to 1 or more solution
	# We ignore the grids where it leads to more than 1 solution.
	solution_count = 0
	try_to_solve_grid(puzzle_grid)
	return solution_count == 1

func try_to_solve_grid(puzzle_grid):
	# This takes in the grid puzzle and tries to solve it recusively
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			if puzzle_grid[row][col] == 0:
				for num in range(1, 10):
					if is_valid(puzzle_grid, row, col, num):
						puzzle_grid[row][col] = num
						try_to_solve_grid(puzzle_grid)
						puzzle_grid[row][col] = 0
				return
	# We keep track of the solution count generated from the current puzzle
	solution_count += 1
	if solution_count > 1:
		return


func _on_hint_button_pressed() -> void:
	var hint = hint_system.generate_hint(puzzle, solution_grid)
	game_grid[hint.row][hint.col].text = str(hint.correct_number)
	_hint_effect(hint)

func _hint_effect(hint):
	var button = game_grid[hint.row][hint.col]
	var stylebox = button.get_theme_stylebox("normal").duplicate(true)
	stylebox.bg_color = HintSystem.HINT_COLORS["default"]
	button.add_theme_stylebox_override("normal", stylebox)
	
	var hint_status = hint_system.get_hint_status()
	var hints_remaining = hint_status["hints_remaining"]

	hint_button.text = "Hint: " + str(hints_remaining)

	if hints_remaining > 0:
		hint_button.text = "Hint: " + str(hints_remaining)
	else:
		hint_button.disabled = true
		hint_button.text = "Hint: 0"
