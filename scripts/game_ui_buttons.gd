extends Control
@onready var note_toggle: Button = $"../CanvasLayer/MarginContainer3/HBoxContainer/note_toggle"

#Buttons
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_reload_pressed() -> void:
	get_tree().reload_current_scene()
