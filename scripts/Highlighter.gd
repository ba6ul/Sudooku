class_name Highlighter
extends Node

func highlight_matching_numbers(GRID_SIZE, game_grid, number: int):
	reset_matching_numbers(GRID_SIZE, game_grid)
	if number <= 0:
		return
		
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			var btn = game_grid[i][j] as Button
			var btn_text = btn.text
			var font_size = btn.get("theme_override_font_sizes/font_size")
			
			#for Notes
			if btn_text == str(number) and font_size == 10:
				#Highlights only if there is 1 node with that value in a sub-grid
				btn.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0, 1))  
			#for ans
			if btn_text == str(number) and font_size == 32 or font_size == 38:
				btn.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0, 1))

				btn.add_theme_color_override("font_outline_color", Color(1.0, 0.5, 0.0, 1))
				btn.add_theme_constant_override("outline_size", 5)  # Thickness of the stroke

				btn.add_theme_font_size_override("font_size", 38)  # Scale

func reset_matching_numbers(GRID_SIZE, game_grid):
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			var btn = game_grid[i][j] as Button
			var font_size = btn.get("theme_override_font_sizes/font_size")
			btn.remove_theme_color_override("font_color")
			btn.remove_theme_color_override("font_outline_color")
			btn.remove_theme_constant_override("outline_size")
			if font_size == 38:
				btn.set("theme_override_font_sizes/font_size", 32)

# Highlights ROW,COL,SUB-GRID
func highlight_related_cells(GRID_SIZE,game_grid,pos: Vector2i):
	reset_cell_colors(GRID_SIZE,game_grid)

	var row = pos[0]
	var col = pos[1]

	# Creates Subgrid
	var subgrid_row_start = int(row / 3) * 3
	var subgrid_col_start = int(col / 3) * 3

	# Loops and Checks row, col, subgrid
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			var btn = game_grid[i][j] as Button
			
			var current_bg_color = btn.get_theme_stylebox("normal").bg_color

			if i == row and j == col:
				# Highlight Selected Button
				btn.modulate = Settings.highlight_modulate
			elif i == row or j == col:
				# Highlight empty ROW and COL
				if current_bg_color != Color.DARK_RED:
					btn.modulate = Settings.highlight_modulate
			elif (i >= subgrid_row_start and i < subgrid_row_start + 3 and
				  j >= subgrid_col_start and j < subgrid_col_start + 3):
				#Highlight sub-Grid
				if current_bg_color !=  Color.DARK_RED:
					btn.modulate = Settings.highlight_modulate

# reset (Highlights ROW,COL,SUB-GRID)
func reset_cell_colors(GRID_SIZE,game_grid):
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):

			var btn = game_grid[i][j] as Button
			btn.modulate = Color(1, 1, 1, 1)
