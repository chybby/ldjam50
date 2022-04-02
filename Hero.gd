extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var GameMap = get_parent()

enum {STATE_NONE, STATE_SHIELD, STATE_WEAPON, STATE_MOVE}
var active_state = STATE_NONE

var shield_angle = 0

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func _input(event):
    if Input.is_action_pressed("choose_shield"):
        active_state = STATE_SHIELD
    elif Input.is_action_pressed("choose_move"):
        active_state = STATE_MOVE
    
    if event is InputEventMouseButton:
        pass
    elif event is InputEventMouseMotion:
        shield_angle = self.get_angle_to(event.position)
        if shield_angle < PI/2:
            shield_angle = 0
        elif shield_angle < PI:
            shield_angle = PI/2
        elif shield_angle < 1.5*PI:
            shield_angle = PI
        else:
            shield_angle = 1.5*PI

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    # 3 options for displaying currently selected thingo:
    # - shield
    # - weapon
    # - move
    if active_state == STATE_NONE:
        get_node("KinematicBody2D/Shield").visible = false
        return
    if active_state == STATE_SHIELD:
#		# get mouse position
#		# display shield dome relatively
        var shield = $KinematicBody2D/Shield
        shield.visible = true
        shield.rotation = shield_angle    
#	if active_state == STATE_WEAPON:
#		# display weapons primed?
#		# cursor with attack icon?
    if active_state == STATE_MOVE:
        # get position on grid
        GameMap.draw_valid_moves(self.position)
        
#		# display valid move blocks?
