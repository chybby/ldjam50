extends Sprite

signal move_finished

var map_position

enum {STATE_NONE, STATE_SHIELD, STATE_WEAPON, STATE_MOVE}
var active_state = STATE_NONE
var previous_state = STATE_NONE
var max_move_distance = 1

enum actions {MOVE, ATTACK_LINE, NOTHING, CHANGE_SHIELD}

onready var game_map = get_parent()

var shield_angle = 0
var shield_angle_select = 0

# TODO: multiple resources or just one?
export var starting_energy = 100
var energy = starting_energy

func draw_valid_moves(valid_moves):
    _draw_valids(valid_moves, 0)
        
func draw_valid_attacks(valid_attacks):
    _draw_valids(valid_attacks, 1)
    
func _draw_valids(valids, i):
    var tile_set = $ValidThingos
    for v in valids:
        tile_set.set_cell(v.x, v.y, i)

func clear_valid_thingos():
    $ValidThingos.clear()

func is_alive():
    return true

func _input(event):
    if not game_map.input_enabled:
        return

    if Input.is_action_pressed("choose_shield"):
        active_state = STATE_SHIELD
        $ValidThingos.clear()
    elif Input.is_action_pressed("choose_move"):
        active_state = STATE_MOVE
        $ValidThingos.clear()
        var vms = game_map.get_valid_moves(map_position, 1)[1]
        draw_valid_moves(vms)
    elif Input.is_action_pressed("choose_weapon"):
        active_state = STATE_WEAPON
        $ValidThingos.clear()
        var vas = game_map.get_valid_line_attacks(map_position)
        draw_valid_attacks(vas)
        

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
        $ValidThingos.clear()

#	if active_state == STATE_WEAPON:
#		# display weapons primed?
#		# cursor with attack icon?
#    if active_state == STATE_MOVE:
        # get position on grid

func _on_GameMap_cell_clicked(position):
    var action_done = false
    if active_state == STATE_MOVE:
        if previous_state == STATE_WEAPON:
            $LaserBeam.play('Fire', true)
            yield($LaserBeam, 'animation_finished')
            $LaserBeam.visible = false
        var is_valid = game_map.move_hero(position)
        if not is_valid:
            return
        energy -= 10
        action_done = true
        active_state = STATE_NONE
        previous_state = STATE_MOVE
    elif active_state == STATE_SHIELD:
        energy -= 5
        action_done = true
        shield_angle = shield_angle_select
        active_state = STATE_NONE
        previous_state = STATE_SHIELD
    elif active_state == STATE_WEAPON:
        active_state = STATE_NONE
        $LaserBeam.visible = true
        $LaserBeam.stop()
        $LaserBeam.play('Fire')
        yield($LaserBeam, 'animation_finished')
        print("about to persist")
        $LaserBeam.play('Persist')
        previous_state = STATE_WEAPON
        action_done = true

    if action_done:
        emit_signal('move_finished')
        
#func shoot_line_laser():
#    if previous_action == actions.ATTACK_LINE:
#        # Play the firing animation backwards.
#        $LaserBeam.play('Fire', true)
#        yield($LaserBeam, 'animation_finished')
#        $LaserBeam.visible = false
#
#    if planned_action == actions.MOVE:
#        var vms = game_map.get_valid_moves(map_position, 1)[0]
#        var next_pos = vms[randi() % vms.size()]
#        game_map.move_enemy(self, next_pos)
#    elif planned_action == actions.ATTACK:
#        $LaserBeam.play('Fire')
#        yield($LaserBeam, 'animation_finished')
#        $LaserBeam.play('Persist')
#    previous_action = planned_action
