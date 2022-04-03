extends Node2D

export (Color,RGB) var selected_c = Color(0.5, 0.74, 0.85)
export (Color,RGB) var unselected_c = Color(0.01,0.66,0.99)
var c = unselected_c
export var selected_width = 10
export var unselected_width = 2
var width = unselected_width
export var radius = 30
export var pts = 5
var zero_vector = Vector2()

func select():
    c = selected_c
    width = selected_width
    self.update()

func unselect():
    c = unselected_c
    width = unselected_width
    self.update()

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func _draw():
    draw_arc(zero_vector, radius, -PI/2, PI/2, pts, c, width, true)
