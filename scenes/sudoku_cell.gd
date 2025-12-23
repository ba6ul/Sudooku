extends Button

signal cell_pressed(cell_self)

# Variables
var grid_pos: Vector2i #CEll location
var subgrid_index: int #Sub-grid Location
var correct_value: int = 0 
var current_value: int = 0
var is_fixed: bool = false #prefilled or not

@onready var label = $NumberLabel # Input

func setup(pos: Vector2i, value: int, solution: int):
	grid_pos = pos
	correct_value = solution
	current_value = value
	# Calculate subgrid index (0-8)
	subgrid_index = (pos.x / 3) * 3 + (pos.y / 3)
	
	if value != 0:
		is_fixed = true
		text = str(value)
	else:
		is_fixed = false
		text = ""

func update_value(new_value: int):
	if is_fixed: return
	current_value = new_value
	text = str(new_value) if new_value != 0 else ""
