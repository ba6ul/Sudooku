## USAGE EXAMPLES
## Copy these patterns into your game scenes (GameManager, MainMenu, etc.)

## ====== FIRST LAUNCH POPUP ======
## Called when game starts for the first time

func _on_first_launch() -> void:
	var config = PopupConfig.first_launch(func(): print("First launch dismissed"))
	
	## Add features to display
	config.features = [
		{
			"icon": "✨",
			"title": "Auto Save",
			"desc": "Your progress saves automatically"
		},
		{
			"icon": "🔥",
			"title": "Streak Mode",
			"desc": "Solve daily to build your streak"
		},
		{
			"icon": "🐛",
			"title": "Bug Fixes",
			"desc": "Fixed grid display issues"
		},
		{
			"icon": "📝",
			"title": "Notes Grid",
			"desc": "Add notes to cells for solving"
		},
	]
	
	PopupManager.show_popup(config)

## ====== EXIT CONFIRMATION POPUP ======
## Called when player presses back/close

func _on_exit_requested() -> void:
	var config = PopupConfig.exit_confirm(
		func(): get_tree().quit(),  ## On confirm
		func(): print("Stay in game")  ## On cancel
	)
	
	PopupManager.show_popup(config)

## ====== SIMPLE ALERT ======
## Generic alert for any message

func _show_alert() -> void:
	var config = PopupConfig.alert(
		"New Level Unlocked!",
		"You've solved 10 puzzles. Hard mode is now available!",
		func(): print("Alert dismissed")
	)
	
	PopupManager.show_popup(config)

## ====== WARNING POPUP ======
## Important warnings (Orange accent color)

func _on_clear_data_request() -> void:
	var config = PopupConfig.warning(
		"Clear All Progress?",
		"This will delete all saved games and progress. This cannot be undone.",
		func(): print("Proceeding with clear...")
	)
	
	PopupManager.show_popup(config)

## ====== QUEUEING MULTIPLE POPUPS ======
## Popups will show one after another automatically

func _show_multiple() -> void:
	PopupManager.show_popup(PopupConfig.alert(
		"Welcome!",
		"This is popup 1",
		func(): print("Done 1")
	))
	
	PopupManager.show_popup(PopupConfig.alert(
		"Here's another",
		"This is popup 2",
		func(): print("Done 2")
	))
	
	# Both will show in sequence

## ====== IN YOUR MAIN GAME SCRIPT ======
## Example integration in your game manager

extends Node

@export var is_first_launch: bool = true

func _ready() -> void:
	if is_first_launch:
		_on_first_launch()
	
	## Listen for exit
	get_tree().root.gui_input.connect(_on_gui_input)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		_on_exit_requested()
