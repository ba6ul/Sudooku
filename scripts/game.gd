extends Node2D
const no_font = preload("res://assets/fonts/Geist-Medium.ttf")

@onready var number_pad: GridContainer = $CanvasLayer/NumberPad
@onready var grid:GridContainer = $CanvasLayer/GridContainer
@onready var button: Button = $Button
@onready var lives_label: Label = $CanvasLayer/MarginContainer2/HBoxContainer/Label
@onready var hint_button: Button = $CanvasLayer/MarginContainer3/HBoxContainer/HintButton
@onready var note_toggle: Button = $CanvasLayer/MarginContainer3/HBoxContainer/note_toggle

var hint_system = HintSystem.new()
var highlighter = Highlighter.new()

var note_mode = false

var lives = 15

# Game Grid
var game_grid = [] # Holds the buttons present in the Game Scene
var puzzle = [] 
var solution_grid = [] # Holds the answer to the puzzle
var solution_count = 0 # No. of valid solution to a solution grid, used only for generating valid grid



var digit_counts = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]  # Track occurrences of each digit (1-9,index 0 unused)

var selected_button:Vector2i = Vector2(-1, -1)
var select_button_answer = 0

const GRID_SIZE = 9


func _ready():
	bind_selectgrid_button_actions()
	init_game()
	
	var hint_status = hint_system.get_hint_status()
	hint_button.text = "Hint: " + str(hint_status["hints_remaining"])
	initialize_digit_counts()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	lives_update()

func init_game():
	_create_empty_grid()
	_fill_grid(solution_grid) # We will get the solution grid
	_create_puzzle(Settings.DIFFICULTY)
	_populate_grid()
	Settings.set_2d_array(solution_grid)
	

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
	style.set_border_width_all(0)
	
	style.border_color = Color(1, 1, 1)

	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_font_override("font", no_font)
	
	if puzzle[row][col] != 0:
		# Theme for pre-filled cells
		var stylebox:StyleBoxFlat = button.get_theme_stylebox("normal").duplicate(true)
		stylebox.bg_color = Settings.Cell_rang
		button.add_theme_stylebox_override("normal", stylebox)
		button.text = str(puzzle[row][col])
	else:
		# Theme for empty cells 
		var stylebox:StyleBoxFlat = button.get_theme_stylebox("normal").duplicate(true)
		stylebox.bg_color = Settings.empty_Cell_rang
		button.add_theme_stylebox_override("normal", stylebox)
		
	button.set("theme_override_font_sizes/font_size", 32)
	
	#Add visual gap between 3x3 subgrids
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
	
	button.custom_minimum_size = Vector2(72, 72) #Setting the button size
	button.pressed.connect(_on_grid_button_pressed.bind(pos, ans))	#grid button press signal
	return button
	
# Single cell press events
func _on_grid_button_pressed(pos: Vector2i, ans):
	selected_button = pos
	select_button_answer = ans
	
	var grid_selected_button = game_grid[pos.x][pos.y]
	var button_text = grid_selected_button.text
	
	# Checks
	var is_prefilled = puzzle[pos.x][pos.y] != 0
	var is_correct_text = button_text != "" and grid_selected_button.get("theme_override_font_sizes/font_size") == 32 and int(button_text) == solution_grid[pos.x][pos.y]
	
	var is_marked_correct = false
	if grid_selected_button.has_theme_color_override("bg_color"):
		is_marked_correct = grid_selected_button.get("theme_override_colors/bg_color") == Settings.Cell_rang_correct

	if is_prefilled or is_correct_text or is_marked_correct:
		disable_numberpad(true)
	else:
		disable_numberpad(false)
		update_numpad_buttons()

	# Highlighting
	if button_text != "" and grid_selected_button.get("theme_override_font_sizes/font_size") == 32:
		var number_to_highlight = int(button_text)
		highlighter.highlight_matching_numbers(GRID_SIZE, game_grid, number_to_highlight)
	
	highlighter.highlight_related_cells(GRID_SIZE, game_grid, pos)


func bind_selectgrid_button_actions():
	for button in number_pad.get_children():
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
						disable_numberpad(true)
					else:
						stylebox.bg_color = Color.DARK_RED
						lives -= 1
						
					if lives == 0:
						get_tree().reload_current_scene()
					btn.add_theme_stylebox_override("normal", stylebox)
					if check_puzzle_solved():
						change_scene()
						
		# Make sure to highlight the cell back after new Input
		highlighter.highlight_related_cells(GRID_SIZE,game_grid,selected_button)
	update_digit_counts(number_pressed)
	highlighter.highlight_matching_numbers(GRID_SIZE, game_grid, number_pressed)


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

			# Ensure only editable cells can be cleared
			if puzzle[row][col] == 0 and grid_selected_button.text != "":
				# Check if the entry being cleared was correct before decrementing
				if grid_selected_button.text != "" and !grid_selected_button.text.contains("\n"):
					var cleared_number = int(grid_selected_button.text)
					# Only decrement if it was correct
					if cleared_number == solution_grid[row][col]:
						digit_counts[cleared_number] -= 1
				
				# Reset the cell styling
				var stylebox:StyleBoxFlat = grid_selected_button.get_theme_stylebox("normal").duplicate(true)
				stylebox.bg_color = Settings.empty_Cell_rang
				grid_selected_button.add_theme_stylebox_override("normal", stylebox)
				
				grid_selected_button.text = ""
				NoteHandler.clear_notes(row, col)
				
				# Make sure to update numpad buttons after clearing
				update_numpad_buttons()
			
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


func initialize_digit_counts():
	# Reset
	for i in range(digit_counts.size()):
		digit_counts[i] = 0
	
	# Count pre-filled Numbers (which are always correct)
	for row in range(GRID_SIZE):
		for col in range(GRID_SIZE):
			var num = puzzle[row][col]
			if num > 0:
				digit_counts[num] += 1
	
	# Update buttons after counting
	update_numpad_buttons()

# Func to ignore note numbers
func update_digit_counts(number_pressed):
	if !note_mode:
		# Only increment if the number is placed correctly
		if selected_button != Vector2i(-1, -1):
			var row = selected_button[0]
			var col = selected_button[1]
			if solution_grid[row][col] == number_pressed:
				digit_counts[number_pressed] += 1
				update_numpad_buttons()
			else:
				# If it's an incorrect entry, don't count it
				# We still update the display for consistency
				update_numpad_buttons()

# decrement digit count, if removed from wrong cells
func decrement_digit_count(number):
	if number > 0 and number <= 9:
		var row = selected_button[0]
		var col = selected_button[1]
		# Only decrement if it was a correct placement being removed
		if solution_grid[row][col] == number:
			digit_counts[number] -= 1
		update_numpad_buttons()

# Disable numpad buttons
func update_numpad_buttons():
	for i in range(1, 10):
		var button = number_pad.get_children()[i-1]
		button.disabled = digit_counts[i] >= 9
		
func disable_numberpad(disabled: bool):
	for button in number_pad.get_children():
		button.disabled = disabled
