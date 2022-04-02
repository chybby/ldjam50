extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export (Color,RGB) var c = Color(50/255.0, 255/255.0, 173/255.0)
export var radius = 30
export var width = 2
export var pts = 5
var zero_vector = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _draw():
    draw_arc(zero_vector, radius, -PI/2, PI/2, pts, c, width, true)
