class_name Highlighter
extends Node


var last_highlighted_number := -1
func highlight_matching_numbers(GRID_SIZE, game_grid, number: int,force_refresh: bool = false):
	
	if number <= 0:
		return
		
	if number == last_highlighted_number and not force_refresh:
		return
		
	reset_all_highlights(GRID_SIZE, game_grid)
	last_highlighted_number = number
	

		
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			
			var btn = game_grid[i][j] as Button
			var btn_text = btn.text
			var font_size = btn.get("theme_override_font_sizes/font_size")
			
			#for Notes
			if btn_text == str(number) and font_size == Settings.NOTE_FONT_SIZE:
				#Highlights only if there is 1 node with that value in a sub-grid
				btn.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0, 1))  
			#for ans
			if btn_text == str(number) :
				btn.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0, 1))

				btn.add_theme_color_override("font_outline_color", Color(1.0, 0.5, 0.0, 1))
				btn.add_theme_constant_override("outline_size", 2)  # Thickness of the stroke

				btn.add_theme_font_size_override("font_size", Settings.HIGHLIGHT_FONT_SIZE)  # Scale
func reset_all_highlights(GRID_SIZE, game_grid):
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			var btn = game_grid[i][j] as Button
			if btn.text.is_empty():
				continue
				
			var font_size = btn.get("theme_override_font_sizes/font_size")
			btn.remove_theme_color_override("font_color")
			btn.remove_theme_color_override("font_outline_color")
			btn.remove_theme_constant_override("outline_size")
			if font_size == Settings.HIGHLIGHT_FONT_SIZE:
				btn.set("theme_override_font_sizes/font_size", Settings.NORMAL_FONT_SIZE)
func reset_matching_numbers(GRID_SIZE, game_grid):
		for i in range(GRID_SIZE):
			for j in range(GRID_SIZE):
				var btn = game_grid[i][j] as Button
				var font_size = btn.get("theme_override_font_sizes/font_size")
				btn.remove_theme_color_override("font_color")
				btn.remove_theme_color_override("font_outline_color")
				btn.remove_theme_constant_override("outline_size")
				if font_size == Settings.HIGHLIGHT_FONT_SIZE:
					btn.set("theme_override_font_sizes/font_size", Settings.NORMAL_FONT_SIZE)
		last_highlighted_number = -1

# Highlights ROW,COL,SUB-GRID
func highlight_related_cells(GRID_SIZE,game_grid,pos: Vector2i):
	var row = pos.x
	var col = pos.y

	# calculate SUB-GRID
	var subgrid_row_start = int(row / 3) * 3
	var subgrid_col_start = int(col / 3) * 3

	# Loop through the the "GRID_SIZE"
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			var btn = game_grid[i][j] as Button
			btn.modulate = Settings.highlight_modulate

		# Highlight Effect condition
			if (i == row or j == col or
				(i >= subgrid_row_start and i < subgrid_row_start + 3 and
				 j >= subgrid_col_start and j < subgrid_col_start + 3)
			):
				btn.modulate = Settings.highlight_modulate # Highlight Effect
			else:
				btn.modulate = Color(1, 1, 1, 1)
