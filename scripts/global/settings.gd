extends Node

# control the difficulty of the game 
# i.e How many empty cells to keep
var DIFFICULTY = 1 #1


# Suggest whether to show user hint on their selection
var SHOW_HINTS = true

#UI
# Cell theme colors — these exist so the user will eventually be able to
# pick a theme (values will become configurable). Do NOT hardcode these
# colors elsewhere; always reference them from here.
const Cell_rang = Color("#3b1578")          # bg for prefilled cells + cells answered correctly
const Cell_rang_correct = Color("#3b1579")  # reserved: bg marker for correctly-solved cells (currently only compared against in game.gd, never applied)
const empty_Cell_rang = Color("#2b2b2b")    # bg for empty/editable cells

#btn.modulate = Color(1.5, 1.2, 0.4, 1) # use for maybe in correct value
var highlight_modulate: Color = Color(2, 2, 2)
const Cell_correct = Color("#ace198")

# Font sizes
const NORMAL_FONT_SIZE = 45
const HIGHLIGHT_FONT_SIZE = 50
const NOTE_FONT_SIZE = 10


var my_2d_array = []

func set_2d_array(array: Array):
	my_2d_array = array

func get_2d_array() -> Array:
	return my_2d_array
