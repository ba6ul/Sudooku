class_name GRIDFEEDBACK
extends Node

const ANIME_TYPE = Tween.TRANS_QUART
const EASE_TYPE = Tween.EASE_OUT

func play_correct_flash(btn: Button, final_color: Color):
	var stylebox = btn.get_theme_stylebox("normal")
	btn.pivot_offset = btn.custom_minimum_size / 2
	var tween = btn.create_tween().set_parallel(true)
	
	#COlOR Anime
	stylebox.bg_color = Color.WHITE
	tween.tween_property(stylebox, "bg_color", Settings.Cell_rang, 0.5).set_trans(ANIME_TYPE).set_ease(EASE_TYPE)
	#SCALE Anime
	btn.scale = Vector2(1.2, 1.2) # Start slightly larger
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func anime_completion(buttons:Array, pivot_index: int):
	for i in range(buttons.size()):
		var btn = buttons[i]
		
		var distance = abs(i - pivot_index)
		var delay = distance * 0.05
		
		var timer = btn.get_tree().create_timer(delay)
		timer.timeout.connect(func(): play_correct_flash(btn, Color.WHITE))
		
