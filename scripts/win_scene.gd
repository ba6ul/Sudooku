extends Control

func _ready() -> void:
	var retrieved_array = Settings.get_2d_array()

	if retrieved_array == [] or retrieved_array.size() != 9:
		retrieved_array = get_test_grid()
		print("No valid grid found. Using test grid.")
	else:
		print("Retrieved 2D array from Settings.")

	var start_pos = Vector2(10, 10)

	for y in range(9):
		for x in range(9):
			var label = Label.new()
			label.text = str(retrieved_array[y][x])
			label.custom_minimum_size = Vector2(50, 50)
			label.position = start_pos + Vector2(x * 60, y * 60)
			label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			#add_child(label)

func get_test_grid() -> Array:
	return [
		[5, 3, 0, 0, 7, 0, 0, 0, 0],
		[6, 0, 0, 1, 9, 5, 0, 0, 0],
		[0, 9, 8, 0, 0, 0, 0, 6, 0],
		[8, 0, 0, 0, 6, 0, 0, 0, 3],
		[4, 0, 0, 8, 0, 3, 0, 0, 1],
		[7, 0, 0, 0, 2, 0, 0, 0, 6],
		[0, 6, 0, 0, 0, 0, 2, 8, 0],
		[0, 0, 0, 4, 1, 9, 0, 0, 5],
		[0, 0, 0, 0, 8, 0, 0, 7, 9],
	]


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
