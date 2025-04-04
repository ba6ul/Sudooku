extends Node2D

const WinScene = preload("res://scenes/win_scene.gd")
@onready var grid:GridContainer = $GridContainer
@onready var button: Button = $Button
@onready var lives_label: Label = $Label
@onready var hint_button: Button = $"UI Buttons/HintButton"
@onready var note_toggle: Button = $"UI Buttons/note_toggle"

var hint_system = HintSystem.new()
var highlighter = Highlighter.new()

var note_mode = false

var lives = 5

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
		
#creates the Sudoku Grid buttons
func create_button(pos:Vector2i):
	var row = pos[0]
	var col = pos[1]
	var ans = solution_grid[row][col]
	
	var button = Button.new()
	button.focus_mode = Control.FOCUS_NONE
	var style = StyleBoxFlat.new()
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	button.add_theme_stylebox_override("normal", style)

	if puzzle[row][col] != 0:
		
		#theme for Pre-fill cell (color is temp)
		var stylebox:StyleBoxFlat = button.get_theme_stylebox("normal").duplicate(true)
		stylebox.bg_color = Settings.Cell_rang
		button.add_theme_stylebox_override("normal", stylebox)
		#Pre=fill NO
		button.text = str(puzzle[row][col])
	else:
		#theme for empty cells 
		var stylebox:StyleBoxFlat = button.get_theme_stylebox("normal").duplicate(true)
		stylebox.bg_color = Settings.empty_Cell_rang
		button.add_theme_stylebox_override("normal", stylebox)
		
	
	button.set("theme_override_font_sizes/font_size", 32)
	
	#v3 Adds gap
	var gap_size = 8
	var gap_Container = MarginContainer.new()
	# Row Gap
	if row > 0 and row % 3 == 0:
		gap_Container.add_theme_constant_override("margin_top", gap_size)
	# Col Gap
	if col > 0 and col % 3 == 0:
		gap_Container.add_theme_constant_override("margin_left", gap_size)
	gap_Container.add_child(button)
	grid.add_child(gap_Container)
	
	button.custom_minimum_size = Vector2(52, 52) #Setting the button size
	button.pressed.connect(_on_grid_button_pressed.bind(pos, ans))	#grid button press signal
	return button

# v4 Highlight
func highlight_related_cells(pos: Vector2i):
	reset_cell_colors()

	var row = pos[0]
	var col = pos[1]

	# Creates Subgrid
	var subgrid_row_start = int(row / 3) * 3
	var subgrid_col_start = int(col / 3) * 3

	# Loops and Checks row, col, subgrid
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			var btn = game_grid[i][j] as Button
			#var stylebox = btn.get_theme_stylebox("normal").duplicate(true)
			#var current_bg_color = stylebox.bg_color
			var current_bg_color = btn.get_theme_stylebox("normal").bg_color

			if i == row and j == col:
				# Highlight Selected Button
				btn.modulate = Settings.highlight_modulate
			elif i == row or j == col:
				# Highlight empty ROW and COL
				if current_bg_color != Settings.Cell_rang_correct and current_bg_color != Color.DARK_RED:
					btn.modulate = Settings.highlight_modulate
			elif (i >= subgrid_row_start and i < subgrid_row_start + 3 and
				  j >= subgrid_col_start and j < subgrid_col_start + 3):
				#Highlight sub-Grid
				if current_bg_color != Settings.Cell_rang_correct and current_bg_color != Color.DARK_RED:
					btn.modulate = Settings.highlight_modulate
			#btn.add_theme_stylebox_override("normal", stylebox)

# Change back color
func reset_cell_colors():
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			
			var btn = game_grid[i][j] as Button
			var is_correct_cell = false
			var stylebox = btn.get_theme_stylebox("normal").duplicate(true)
			var font_size = btn.get("theme_override_font_sizes/font_size")
			
			
			if btn.text != "" and btn.get("theme_override_font_sizes/font_size") == 32:
				if int(btn.text) == solution_grid[i][j]:
					is_correct_cell = true
			if not (Settings.SHOW_HINTS and btn.text != "" and 
				   ((int(btn.text) == solution_grid[i][j] and stylebox.bg_color == Settings.Cell_rang_correct) or
					(int(btn.text) != solution_grid[i][j] and stylebox.bg_color == Color.DARK_RED))):
					pass#stylebox.bg_color = Settings.empty_Cell_rang
				
			btn.add_theme_stylebox_override("normal", stylebox)
			btn.modulate = Color(1, 1, 1, 1)
			


			
			if font_size == 10:
				#write somthing to reset text and add it here
				pass

func _on_grid_button_pressed(pos: Vector2i, ans):
	selected_button = pos
	select_button_answer = ans
	highlight_related_cells(pos)
	var grid_selected_button = game_grid[selected_button[0]][selected_button[1]]
		
		
	# Disable Numbers logic
	if grid_selected_button.text != "" and puzzle[pos[0]][pos[1]] != 0:
		# Disable for pre-filled cells
		for button in $SelectGrid.get_children():
			button.disabled = true
	elif grid_selected_button.text != "" and grid_selected_button.get("theme_override_font_sizes/font_size") == 32 and int(grid_selected_button.text) == solution_grid[pos[0]][pos[1]]:
		# Disable for Correct ans
		for button in $SelectGrid.get_children():
			button.disabled = true
	else:
		# Enable for (empty cells, notes, incorrect)
		for button in $SelectGrid.get_children():
			button.disabled = false
			
			
	# highlight same numbers matching instances
	if grid_selected_button.text != "":
		var number_to_highlight = 0
		# Check if it's a note or a regular number
		if grid_selected_button.get("theme_override_font_sizes/font_size") == 32:
			number_to_highlight = int(grid_selected_button.text)
		highlight_related_cells(pos)
		highlighter.highlight_matching_numbers(GRID_SIZE, game_grid, number_to_highlight)
	else:
		# Just highlight related cells if no number
		highlight_related_cells(pos)
	


func bind_selectgrid_button_actions():
	for button in $SelectGrid.get_children():
		var b = button as Button
		b.pressed.connect(_on_selectgrid_button_pressed.bind(int(b.text)))

func _on_selectgrid_button_pressed(number_pressed):
	if selected_button != Vector2i(-1, -1):
		var row = selected_button[0]
		var col = selected_button[1]
		var grid_selected_button = game_grid[row][col]
		
		if puzzle[row][col] == 0:  # Only for editable cells
			if note_mode:
				# Handle note mode
				grid_selected_button.set("theme_override_font_sizes/font_size", 10)
				
				# Add or remove note
				NoteHandler.add_note(row, col, number_pressed)
				
				# Update button text with formatted notes
				if NoteHandler.has_notes(row, col):
					grid_selected_button.text = NoteHandler.get_formatted_note_text(row, col)
				else:
					grid_selected_button.text = ""
			else:
				# Normal mode - enter number
				grid_selected_button.text = str(number_pressed)
				grid_selected_button.set("theme_override_font_sizes/font_size", 32)
				
				# Red/Green
				if Settings.SHOW_HINTS:
					var result_match = (number_pressed == select_button_answer)
					
					var btn = game_grid[selected_button[0]][selected_button[1]] as Button
					
					var stylebox:StyleBoxFlat = btn.get_theme_stylebox("normal").duplicate(true)
					if result_match == true:
						stylebox.bg_color = Settings.Cell_rang_correct #Color.SEA_GREEN 
						
					else:
						stylebox.bg_color = Color.DARK_RED
						lives -= 1
						
					if lives == 0:
						get_tree().reload_current_scene()
					btn.add_theme_stylebox_override("normal", stylebox)
					if check_puzzle_solved():
						change_scene()
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
				var stylebox:StyleBoxFlat = button.get_theme_stylebox("normal").duplicate(true)
				stylebox.bg_color = Settings.empty_Cell_rang
				button.add_theme_stylebox_override("normal", stylebox)

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


#Buttons

func _on_hint_button_pressed() -> void:
	var hint = hint_system.generate_hint(puzzle, solution_grid)
	game_grid[hint.row][hint.col].text = str(hint.correct_number)
	_hint_effect(hint)

func _on_clear_button_pressed() -> void:
	if selected_button != Vector2i(-1, -1):
		var row = selected_button[0]
		var col = selected_button[1]
		var grid_selected_button = game_grid[row][col]

		# Ensure only editable cells can be cleared and prevent clearing correct answers
		if puzzle[row][col] == 0 and grid_selected_button.text != str(solution_grid[row][col]):
			grid_selected_button.text = ""
			reset_cell_colors()
			NoteHandler.clear_notes(row, col)
			
func check_puzzle_solved() -> bool:
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			var btn = game_grid[i][j] as Button
			if int(btn.text) != solution_grid[i][j]:
				return false
	return true
	
func change_scene():
	print("Done")
	get_tree().change_scene_to_file("res://scenes/win_scene.tscn")


func _on_note_toggle_pressed() -> void:
	note_mode = !note_mode
	print("Note mode: " + ("ON" if note_toggle else "OFF"))
	
	if note_mode:
		note_toggle.text = "Note: ON"
		note_toggle.set("theme_override_colors/font_focus_color" ,Color.DARK_SLATE_BLUE)
	else:
		note_toggle.text = "Note: OFF"
		note_toggle.set("theme_override_colors/font_focus_color" ,Color.WHITE)
		print(note_toggle.text)
