extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum {STATE_NONE, STATE_SHIELD, STATE_WEAPON, STATE_MOVE}
var active_state = STATE_NONE

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    # 3 options for displaying currently selected thingo:
    # - shield
    # - weapon
    # - move
#	if active_state == STATE_NONE:
#		return
#	if active_state == STATE_SHIELD:
#		# get mouse position
#		# display shield dome relatively
#	if active_state == STATE_WEAPON:
#		# display weapons primed?
#		# cursor with attack icon?
#	if active_state == STATE_MOVE:
#		# display valid move blocks?
    pass
    
