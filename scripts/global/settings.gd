extends Node

# control the difficulty of the game 
# i.e How many empty cells to keep
var DIFFICULTY = 1 #1


# Suggest whether to show user hint on their selection
var SHOW_HINTS = true

#UI
const Cell_rang = Color("#3b1578")
const Cell_rang_correct = Color("#3b1579") #add the cell color 
const empty_Cell_rang = Color("#2b2b2b") 

#btn.modulate = Color(1.5, 1.2, 0.4, 1) # use for maybe in correct value
var highlight_modulate: Color = Color(2, 2, 2)
const Cell_correct = Color("#ace198")


var my_2d_array = []

func set_2d_array(array: Array):
	my_2d_array = array

func get_2d_array() -> Array:
	return my_2d_array
