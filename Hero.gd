extends Sprite


var map_position

enum {STATE_NONE, STATE_SHIELD, STATE_WEAPON, STATE_MOVE}
var active_state = STATE_NONE
var max_move_distance = 1

var shield_angle = 0
var shield_angle_select = 0

# TODO: multiple resources or just one?
export var energy = 100

func draw_valid_moves(valid_moves):
    var tile_set = $ValidMoves
    for v in valid_moves:
        tile_set.set_cell(v.x, v.y, 0)

func clear_valid_moves():
    $ValidMoves.clear()

func is_alive():
    return true

func _input(event):
    if Input.is_action_pressed("choose_shield"):
        active_state = STATE_SHIELD
        $ValidMoves.clear()
    elif Input.is_action_pressed("choose_move"):
        active_state = STATE_MOVE

    if event is InputEventMouseMotion and active_state == STATE_SHIELD:
        shield_angle_select = get_shield_angle(event.position)
        
func get_shield_angle(position):
    shield_angle_select = $ShieldPosition.get_angle_to(position)
    if shield_angle_select < -3*PI/4:
        shield_angle_select = PI
    elif shield_angle_select < -PI/4:
        shield_angle_select = -PI/2
    elif shield_angle_select < PI/4:
        shield_angle_select = 0
    elif shield_angle_select < 3*PI/4:
        shield_angle_select = PI/2
    else:
        shield_angle_select = PI
    return shield_angle_select

func _process(delta):
    # 3 options for displaying currently selected thingo:
    # - shield
    # - weapon
    # - move
    if active_state == STATE_SHIELD:
#		# get mouse position
#		# display shield dome relatively
        $Shield.rotation = shield_angle_select
        $Shield.select()
    else:
        $Shield.rotation = shield_angle
        $Shield.unselect()
    if active_state == STATE_NONE:
        $ValidMoves.clear()
#	if active_state == STATE_WEAPON:
#		# display weapons primed?
#		# cursor with attack icon?
#    if active_state == STATE_MOVE:
        # get position on grid
