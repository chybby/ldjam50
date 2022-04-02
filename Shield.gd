extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var c = Color(241, 255, 173)
export var radius = 30
export var width = 2
var zero_vector = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _draw():
	draw_arc(zero_vector, radius, 0, PI/1.5, 10, c, width, true)
