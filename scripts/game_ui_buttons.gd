extends Control
@onready var note_toggle: Button = $"../CanvasLayer/MarginContainer3/HBoxContainer/note_toggle"
const SaveSystem = preload("res://scripts/SaveSystem.gd")
#Buttons
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_reload_pressed() -> void:
	# 2. Delete the current save file first!
	SaveSystem.delete_save(Settings.DIFFICULTY)
	
	# 3. Now when the scene reloads, init_game() will see no save file
	# and will generate a fresh board.
	get_tree().reload_current_scene()
