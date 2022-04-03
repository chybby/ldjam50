extends Node2D

signal move_finished
signal hero_died
signal energy_changed(new_energy)

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
    return energy > 0

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
        var vas = get_valid_line_attacks(map_position, $Sprite.rotation)
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

func is_shield_pointing_at_enemy(enemy):
    var shield_vector = Vector2.RIGHT.rotated(shield_angle)
    var hero_to_enemy = enemy.position - position
    return int(hero_to_enemy.angle_to(shield_vector)) == 0

func use_energy(energy_used):
    energy -= energy_used
    emit_signal('energy_changed', energy)
    if energy < 0:
        position = Vector2(-200, -200)
        emit_signal('hero_died')
    if energy == 0:
        $Shield.visible = false

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

func get_valid_line_attacks(position, rotation):
    var valid_moves_rel = []
    for y in range(-1, -position.y-1, -1):
        valid_moves_rel.append(Vector2(0, y))
    for x in range(1, game_map.width):
        valid_moves_rel.append(Vector2(x, 0))
    for y in range(1, game_map.height):
        valid_moves_rel.append(Vector2(0, y))
    for x in range(-1, -position.x-1, -1):
        valid_moves_rel.append(Vector2(x, 0))

    return valid_moves_rel

func is_valid_attack(clicked_map_position) -> bool:
    var vas = get_valid_line_attacks(position, rotation)
    var found = false
    for v in vas:
        v += map_position
        if clicked_map_position == v:
            found = true
            break
    return found

func _on_GameMap_cell_clicked(clicked_map_position):
    var action_done = false
    if active_state == STATE_MOVE:
        if not game_map.is_valid_move(map_position, clicked_map_position, 1):
            game_map.input_enabled = true
            return

        if previous_state == STATE_WEAPON:
            $Sprite/LaserBeam.play('Fire', true)
            yield($Sprite/LaserBeam, 'animation_finished')
            $Sprite/LaserBeam.visible = false
            $Sprite/LaserBeam.get_node('Area2D/CollisionShape2D').disabled = true

        var look_vector = game_map.map_to_world(clicked_map_position) - position
        game_map.move_hero(clicked_map_position)

        $Sprite.look_at(position + look_vector + Vector2(32, 32))
        $Sprite.rotation += PI/2
        use_energy(10)

        action_done = true
        active_state = STATE_NONE
        previous_state = STATE_MOVE
    elif active_state == STATE_SHIELD:
        if shield_angle != shield_angle_select:
            shield_angle = shield_angle_select
            action_done = true
        active_state = STATE_NONE
        previous_state = STATE_SHIELD
    elif active_state == STATE_WEAPON:
        if not is_valid_attack(clicked_map_position):
            game_map.input_enabled = true
            return

        active_state = STATE_NONE
        var look_vector = game_map.map_to_world(clicked_map_position) - position
        $Sprite.look_at(position + look_vector + Vector2(32, 32))
        $Sprite.rotation += PI/2
        $Sprite/LaserBeam.visible = true
        $Sprite/LaserBeam.stop()
        $Sprite/LaserBeam.play('Fire')
        yield($Sprite/LaserBeam, 'animation_finished')
        $Sprite/LaserBeam.get_node('Area2D/CollisionShape2D').disabled = false
        $Sprite/LaserBeam.play('Persist')
        previous_state = STATE_WEAPON
        action_done = true

    if action_done:
        emit_signal('move_finished')
        for area in $Area2D.get_overlapping_areas():
            _on_Area2D_area_entered(area)

func _on_Area2D_area_entered(area: Area2D):
    if area.collision_layer == 2:  # Weapons.
        print('Player entered weapon area of enemy: ', area.get_parent().get_parent())
        var enemy = area.get_parent().get_parent()
        if is_shield_pointing_at_enemy(enemy):
            use_energy(20)
        else:
            position = Vector2(-200, -200)
            emit_signal('hero_died')
    elif area.collision_layer == 3:  # Pickups.
        print('Player entered area of pickup: ', area.get_parent().get_parent())
        pass
