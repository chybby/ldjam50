extends Sprite


var map_position
onready var GameMap = get_parent()

enum {STATE_NONE, STATE_SHIELD, STATE_WEAPON, STATE_MOVE}
var active_state = STATE_NONE
var max_move_distance = 2

var shield_angle = 0

func _input(event):
    if Input.is_action_pressed("choose_shield"):
        active_state = STATE_SHIELD
    elif Input.is_action_pressed("choose_move"):
        active_state = STATE_MOVE

    if event is InputEventMouseButton:
        pass
    elif event is InputEventMouseMotion:
        shield_angle = $ShieldPosition.get_angle_to(event.position)
        print(shield_angle)
        if shield_angle < -3*PI/4:
            shield_angle = PI
        elif shield_angle < -PI/4:
            shield_angle = -PI/2
        elif shield_angle < PI/4:
            shield_angle = 0
        elif shield_angle < 3*PI/4:
            shield_angle = PI/2
        else:
            shield_angle = PI

func _process(delta):
    # 3 options for displaying currently selected thingo:
    # - shield
    # - weapon
    # - move
    if active_state == STATE_NONE:
        $Shield.visible = false
        return
    if active_state == STATE_SHIELD:
#		# get mouse position
#		# display shield dome relatively
        var shield = $Shield
        shield.visible = true
        shield.rotation = shield_angle

#	if active_state == STATE_WEAPON:
#		# display weapons primed?
#		# cursor with attack icon?
    if active_state == STATE_MOVE:
        # get position on grid
        GameMap.draw_valid_moves(self.position, max_move_distance)
        

#		# display valid move blocks?
