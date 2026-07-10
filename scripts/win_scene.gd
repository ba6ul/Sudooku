extends CanvasLayer

const SaveSystem = preload("res://scripts/SaveSystem.gd")

func _ready() -> void:
	var retrieved_array = Settings.get_2d_array()
	

	
	var start_pos = Vector2(10, 10)
#
	#for y in range(9):
		#for x in range(9):
			#var label = Label.new()
			#label.text = str(retrieved_array[y][x])
			#label.custom_minimum_size = Vector2(50, 50)
			#label.position = start_pos + Vector2(x * 60, y * 60)
			#label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			#label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			##add_child(label)
#


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


func _on_button_pressed() -> void:
	# 2. Delete the current save file first!
	SaveSystem.delete_save(Settings.DIFFICULTY)
	
	# 3. Now when the scene reloads, init_game() will see no save file
	# and will generate a fresh board.
	get_tree().reload_current_scene()
