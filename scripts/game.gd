extends Node2D

@onready var grid:GridContainer = $GridContainer
@onready var button: Button = $Button

const cell_rang = Color.YELLOW #add the cell color

# Game Grid
var game_grid = [] # Holds the buttons present in the Game Scene
var puzzle = [] # Holds the puzzle
var solution_grid = [] # Holds the answer to the puzzle
var solution_count = 0 # No. of valid solution to a solution grid, used only for generating valid grid

var selected_button:Vector2i = Vector2(-1, -1)
var select_button_answer = 0

const GRID_SIZE = 9

# Called when the node enters the scene tree for the first time.
func _ready():
	bind_selectgrid_button_actions()
	init_game()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

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
	stylebox.bg_color = cell_rang
	button.add_theme_stylebox_override("normal", stylebox)
	
	
	button.custom_minimum_size = Vector2(52, 52)
	button.pressed.connect(_on_grid_button_pressed.bind(pos, ans))
	grid.add_child(button)
	return button

func _on_grid_button_pressed(pos: Vector2i, ans):
	selected_button = pos
	select_button_answer = ans # This variable tracks of the answer for the selected button in Scene

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
			btn.add_theme_stylebox_override("normal", stylebox)
	

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
