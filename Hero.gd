extends Node2D

signal move_finished
signal hero_died
signal energy_changed(new_energy)

var map_position

enum {STATE_NONE, STATE_SHIELD, STATE_WEAPON, STATE_MOVE}
var active_state = STATE_NONE
var max_move_distance = 1

onready var game_map = get_parent()

var shield_angle = 0
var shield_angle_select = 0

# TODO: multiple resources or just one?
export var starting_energy = 100
var energy = starting_energy

func draw_valid_moves(valid_moves):
    var tile_set = $ValidMoves
    for v in valid_moves:
        tile_set.set_cell(v.x, v.y, 0)

func clear_valid_moves():
    $ValidMoves.clear()

func is_alive():
    return true

func _input(event):
    if not game_map.input_enabled:
        return

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

func is_shield_pointing_at_enemy(enemy):
    var shield_vector = Vector2.RIGHT.rotated(shield_angle)
    var hero_to_enemy = enemy.position - position
    print('shield vector ', shield_vector)
    print('hero_to_enemy ', hero_to_enemy)
    print('angle ', hero_to_enemy.angle_to(shield_vector))
    return int(hero_to_enemy.angle_to(shield_vector)) == 0

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

    if active_state == STATE_MOVE:
        var vms = game_map.get_valid_moves(map_position, 1)[1]
        for v in vms:
            draw_valid_moves(vms)
#	if active_state == STATE_WEAPON:
#		# display weapons primed?
#		# cursor with attack icon?
#    if active_state == STATE_MOVE:
        # get position on grid

func _on_GameMap_cell_clicked(position):
    var action_done = false
    if active_state == STATE_MOVE:
        var look_vector = game_map.map_to_world(position) - self.position
        var is_valid = game_map.move_hero(position)
        if not is_valid:
            return
        print(self.position + look_vector)
        $Sprite.look_at(self.position + look_vector + Vector2(32, 32))
        $Sprite.rotation += PI/2
        energy -= 10
        emit_signal('energy_changed', energy)
        action_done = true
        active_state = STATE_NONE
    elif active_state == STATE_SHIELD:
        if shield_angle != shield_angle_select:
            shield_angle = shield_angle_select
            action_done = true
        active_state = STATE_NONE

    if energy <= 0:
        emit_signal('hero_died')

    if action_done:
        emit_signal('move_finished')

func _on_Area2D_area_entered(area):
    #TODO: figure out if this is a weapon or battery. Assume weapon for now.
    print('Player entered weapon area of enemy: ', area.get_parent().get_parent())
    var enemy = area.get_parent().get_parent()
    if is_shield_pointing_at_enemy(enemy):
        energy -= 20
        emit_signal('energy_changed', energy)
    else:
        position = Vector2(-200, -200)
        emit_signal('hero_died')
