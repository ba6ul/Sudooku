class_name NumpadManager

var _number_pad: GridContainer
var _digit_counts: Array
var _scene_node: Node


func setup(number_pad: GridContainer, digit_counts: Array, scene_node: Node) -> void:
	_number_pad = number_pad
	_digit_counts = digit_counts
	_scene_node = scene_node
	_create_badges()


# === Public API ===

# Call after any digit count change
func refresh() -> void:
	var is_globally_locked = _is_globally_locked()
	
	for i in range(1, 10):
		var btn = _number_pad.get_child(i - 1) as Button
		var remaining = 9 - _digit_counts[i]
		
		# Always update badges regardless of lock state
		_update_badge(btn, remaining)
		
		# Only update per-digit disabled state if not globally locked
		if not is_globally_locked:
			btn.disabled = remaining <= 0


# Call when user selects a prefilled/correct/empty cell
func lock(disabled: bool) -> void:
	for btn in _number_pad.get_children():
		btn.disabled = disabled
	
	# If unlocking, re-apply per-digit rules immediately
	if not disabled:
		refresh()


# === Private ===

func _is_globally_locked() -> bool:
	return _number_pad.get_children().all(func(b): return b.disabled)


func _update_badge(btn: Button, remaining: int) -> void:
	var badge_container = btn.get_node_or_null("BadgeContainer")
	if not badge_container:
		return
	
	if remaining <= 0:
		badge_container.visible = false
	else:
		var badge = badge_container.get_node("Badge") as Label
		if badge.text != str(remaining):
			badge.text = str(remaining)
			_pop_badge(badge_container)
		badge_container.visible = true


func _pop_badge(badge_container: Control) -> void:
	badge_container.pivot_offset = badge_container.size / 2.0
	badge_container.scale = Vector2.ONE
	
	var tween = _scene_node.create_tween()
	tween.tween_property(badge_container, "scale", Vector2(1.4, 1.4), 0.1) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(badge_container, "scale", Vector2.ONE, 0.15) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)


func _create_badges() -> void:
	for i in range(1, 10):
		var btn = _number_pad.get_child(i - 1)
		
		var existing = btn.get_node_or_null("BadgeContainer")
		if existing:
			existing.queue_free()
		
		var badge_container = Control.new()
		badge_container.name = "BadgeContainer"
		badge_container.set_anchors_preset(Control.PRESET_TOP_LEFT)
		badge_container.position = Vector2(8, 4)
		badge_container.size = Vector2(16, 16)
		badge_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.45, 0.2, 0.7, 1.0)
		style.set_corner_radius_all(8)
		
		var circle_panel = Panel.new()
		circle_panel.name = "CirclePanel"
		circle_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		circle_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		circle_panel.add_theme_stylebox_override("panel", style)
		
		var badge = Label.new()
		badge.name = "Badge"
		badge.text = str(9 - _digit_counts[i])
		badge.add_theme_font_size_override("font_size", 10)
		badge.add_theme_color_override("font_color", Color.WHITE)
		badge.set_anchors_preset(Control.PRESET_FULL_RECT)
		badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		badge_container.add_child(circle_panel)
		badge_container.add_child(badge)
		btn.add_child(badge_container)
