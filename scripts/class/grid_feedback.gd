class_name GRIDFEEDBACK
extends Node

const ANIME_TYPE = Tween.TRANS_QUART
const EASE_TYPE = Tween.EASE_OUT

#rename it to flash and animation
func play_correct_anime(btn: Button, final_color: Color):
	
	if not is_instance_valid(btn):
		return
		
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
		
		if not is_instance_valid(btn):
			return
		
		var distance = abs(i - pivot_index)
		var delay = distance * 0.05
		
		var timer = btn.get_tree().create_timer(delay)
		timer.timeout.connect(func(): play_correct_anime(btn, Color.WHITE))
		
func play_incorrect_anime(btn:Button):
	var original_pos = btn.position
	var tween = btn.create_tween()
	
	for i in range(4):
		tween.tween_property(btn, "position", original_pos + Vector2(5,0), 0.05)
		tween.tween_property(btn, "position", original_pos + Vector2(-5, 0), 0.05)
	tween.tween_property(btn, "position", original_pos, 0.05)
