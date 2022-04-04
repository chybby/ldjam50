extends Node2D

signal hero_died
signal energy_changed(new_energy)
signal potential_energy_use_changed(new_potential_energy_use)

var map_position

enum state {NONE, SHIELD, LINE_WEAPON, AREA_WEAPON, MOVE}
var active_state = state.NONE
var previous_state = state.NONE
var max_move_distance = 1

onready var game_map = get_parent()

var mouse_map_position = Vector2(7, 3)
var mouse_angle = -PI/2

var shield_angle = -PI/2

export var line_attack_cost = 1
export var area_attack_cost = 2
export var shield_cost = 2
export var move_cost = 1

# TODO: multiple resources or just one?
export var starting_energy = 10
var energy = starting_energy

var playing_turn = false
var just_finished_turn = false
var really_finished_turn = false

var is_alive = true

var areas_collided_this_turn = []

func reset():
    is_alive = true
    $Sprite.rotation = 0
    shield_angle = -PI/2
    $Shield.visible = true
    $Sprite/LaserBeam.visible = false
    energy = starting_energy
    active_state = state.NONE
    previous_state = state.NONE
    playing_turn = false
    just_finished_turn = false
    really_finished_turn = false
    areas_collided_this_turn = []
    mouse_map_position = Vector2(7, 3)
    mouse_angle = -PI/2

func draw_valid_moves(valid_moves):
    _draw_valids(valid_moves, 1)

func draw_valid_attacks(valid_attacks):
    _draw_valids(valid_attacks, 0)

func _draw_valids(valids, i):
    var tile_map = $ValidThingos
    for v in valids:
        tile_map.set_cellv(v, i)
    tile_map.update_bitmask_region()

func clear_valid_thingos():
    $ValidThingos.clear()

func _input(event):
    if not game_map.input_enabled:
        return

    if Input.is_action_just_pressed("choose_shield"):
        activate_state(state.SHIELD)
    elif Input.is_action_just_pressed("choose_move"):
        activate_state(state.MOVE)
    elif Input.is_action_just_pressed("choose_line_weapon"):
        activate_state(state.LINE_WEAPON)
    elif Input.is_action_just_pressed("choose_area_weapon"):
        activate_state(state.AREA_WEAPON)

    if event is InputEventMouseMotion:
        mouse_angle = get_angle(event.position)
        mouse_map_position = game_map.world_to_map(event.position)

func activate_state(new_state):
    if new_state == state.SHIELD:
        active_state = state.SHIELD
        $ValidThingos.clear()
    elif new_state == state.MOVE:
        active_state = state.MOVE
        $ValidThingos.clear()
        var vms = game_map.get_valid_moves(map_position, 1)[1]
        draw_valid_moves(vms)
    elif new_state == state.LINE_WEAPON:
        active_state = state.LINE_WEAPON
    elif new_state == state.AREA_WEAPON:
        active_state = state.AREA_WEAPON

func get_angle(position):
    var angle_select = $ShieldPosition.get_angle_to(position)
    if angle_select < -3*PI/4:
        angle_select = PI
    elif angle_select < -PI/4:
        angle_select = -PI/2
    elif angle_select < PI/4:
        angle_select = 0
    elif angle_select < 3*PI/4:
        angle_select = PI/2
    else:
        angle_select = PI
    return angle_select

func is_shield_pointing_at_enemy(enemy):
    var shield_vector = Vector2.RIGHT.rotated(shield_angle)
    var hero_to_enemy = enemy.position - position
    return round(hero_to_enemy.angle_to(shield_vector)) == 0

func potentially_use_energy(energy):
    emit_signal('potential_energy_use_changed', energy)

func use_energy(energy_used):
    var old_energy = energy

    energy -= energy_used
    if energy > starting_energy:
        energy = starting_energy

    if energy == old_energy:
        return

    emit_signal('energy_changed', energy)
    if energy < 0:
        position = Vector2(-200, -200)
        is_alive = false
        emit_signal('hero_died')
    elif energy == 0:
        $Shield.visible = false
    else:
        $Shield.visible = true

func _process(delta):
    if active_state == state.SHIELD:
        potentially_use_energy(0)
        $Shield.rotation = mouse_angle
        $Shield.select()
    else:
        $Shield.rotation = shield_angle
        $Shield.unselect()

    if active_state == state.LINE_WEAPON:
        potentially_use_energy(line_attack_cost)
        var look_vector = Vector2.RIGHT.rotated(mouse_angle)
        look_vector.x = round(look_vector.x)
        look_vector.y = round(look_vector.y)
        $Sprite.look_at(position + look_vector + Vector2(32, 32))
        $Sprite.rotation += PI/2
        var valids = get_valid_line_attacks(map_position, look_vector)
        $ValidThingos.clear()
        draw_valid_attacks(valids)
    elif active_state == state.AREA_WEAPON:
        potentially_use_energy(area_attack_cost)
        var valids = get_valid_area_attacks(map_position, mouse_map_position)
        $ValidThingos.clear()
        draw_valid_attacks(valids)
    elif active_state == state.MOVE:
        potentially_use_energy(move_cost)
    elif active_state == state.NONE:
        potentially_use_energy(0)
        $ValidThingos.clear()

func get_valid_line_attacks(position, look_vector):
    var valid_moves_rel = []
    if look_vector == Vector2.UP:
        for y in range(-1, -position.y-1, -1):
            valid_moves_rel.append(Vector2(0, y))
    elif look_vector == Vector2.RIGHT:
        for x in range(1, game_map.width - position.x):
            valid_moves_rel.append(Vector2(x, 0))
    elif look_vector == Vector2.DOWN:
        for y in range(1, game_map.height - position.y):
            valid_moves_rel.append(Vector2(0, y))
    elif look_vector == Vector2.LEFT:
        for x in range(-1, -position.x-1, -1):
            valid_moves_rel.append(Vector2(x, 0))

    return valid_moves_rel

func get_valid_area_attacks(position, mouse_position):
    var valid_moves_rel = []

    var middle = mouse_position - position

    for x in [-1, 0, 1]:
        for y in [-1, 0, 1]:
            var relative = middle + Vector2(x, y)
            var absolute = relative + position
            if absolute.x < 0 or absolute.x >= game_map.width:
                continue
            if absolute.y < 0 or absolute.y >= game_map.height:
                continue
            valid_moves_rel.append(relative)

    return valid_moves_rel

func _on_GameMap_cell_clicked(clicked_map_position):
    var action_done = false
    areas_collided_this_turn.clear()
    if active_state == state.MOVE:
        if not game_map.is_valid_move(map_position, clicked_map_position, 1):
            game_map.input_enabled = true
            return
        $ValidThingos.clear()

        $MoveSound.play()
        use_energy(move_cost)
        var look_vector = game_map.map_to_world(clicked_map_position) - position
        var tween = $Tween

        print($Sprite.rotation)
        var current_rotation = $Sprite.rotation
        $Sprite.look_at(position + look_vector + Vector2(32, 32))
        $Sprite.rotation += PI/2
        var desired_rotation = $Sprite.rotation

        if abs(desired_rotation - current_rotation) > abs(desired_rotation - 2*PI - current_rotation):
            desired_rotation -= 2*PI
        elif abs(desired_rotation - current_rotation) > abs(desired_rotation + 2*PI - current_rotation):
            desired_rotation += 2*PI

        if current_rotation != desired_rotation:
            tween.interpolate_property($Sprite, "rotation",
                    current_rotation, desired_rotation, 1,
                    Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
            tween.start()
            yield(tween, 'tween_completed')

        tween.interpolate_property(self, "position",
                position, game_map.map_to_world(clicked_map_position), 1,
                Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
        tween.start()
        yield(tween, 'tween_completed')

        game_map.move_hero(clicked_map_position)

        action_done = true
        active_state = state.NONE
        previous_state = state.MOVE
    elif active_state == state.SHIELD:
        if shield_angle != mouse_angle:
            $ShieldSelectSound.play()
            shield_angle = mouse_angle
            action_done = true
        active_state = state.NONE
        previous_state = state.SHIELD
        game_map.input_enabled = true
    elif active_state == state.LINE_WEAPON:
        active_state = state.NONE
        use_energy(line_attack_cost)

        # Firing the lazar blarrrrr!
        $LineAttackSound.play()
        $Sprite/LaserBeam.visible = true
        $Sprite/LaserBeam.stop()
        $Sprite/LaserBeam.play('Fire')
        yield($Sprite/LaserBeam, 'animation_finished')
        $Sprite/LaserBeam.get_node('Area2D/CollisionShape2D').disabled = false
        $Sprite/LaserBeam.play('Persist')
        yield(get_tree().create_timer(0.5), 'timeout')
        $Sprite/LaserBeam.play('Fire', true)
        yield($Sprite/LaserBeam, 'animation_finished')
        $Sprite/LaserBeam.visible = false
        $Sprite/LaserBeam.get_node('Area2D/CollisionShape2D').disabled = true

        previous_state = state.LINE_WEAPON
        action_done = true
    elif active_state == state.AREA_WEAPON:
        $AreaAttackSound.play()
        active_state = state.NONE
        use_energy(area_attack_cost)

        $Node2D/Missile.global_position = game_map.map_to_world(clicked_map_position)
        $Node2D/Missile.visible = true
        $Node2D/Missile/Area2D/CollisionShape2D.disabled = false
        yield(get_tree().create_timer(1.0), 'timeout')
        $Node2D/Missile.visible = false
        $Node2D/Missile/Area2D/CollisionShape2D.disabled = true

        previous_state = state.AREA_WEAPON
        action_done = true
    elif active_state == state.NONE:
        game_map.input_enabled = true

    if action_done:
        playing_turn = false
        just_finished_turn = true

func handle_collision(area):
    areas_collided_this_turn.append(area)
    print('Player entered area: ', area)
    print('Area layer: ', area.collision_layer)
    if area.get_collision_layer_bit(1):  # Weapons.
        var enemy = area.get_parent().get_parent()
        print('Player entered weapon area of enemy: ', enemy)
        if is_shield_pointing_at_enemy(enemy):
            use_energy(shield_cost)
        else:
            position = Vector2(-200, -200)
            is_alive = false
            emit_signal('hero_died')
    elif area.get_collision_layer_bit(2):  # Pickups.
        var pickup = area.get_parent()
        print('Player entered area of pickup: ', pickup)
        $Pickup.play()
        pickup.pickup_effect()
        game_map.remove_pickup(pickup.map_position)

func handle_collisions():
    print('handle_collisions overlapping areas: ', $Hitbox.get_overlapping_areas())
    var areas = $Hitbox.get_overlapping_areas()
    for area in areas:
        print('Hero entered area via call from main')
        if not area in areas_collided_this_turn:
            handle_collision(area)
        else:
            print('Ignoring collision already handled')

func _on_Hitbox_area_entered(area: Area2D):
    print('Hero entered area via signal')
    handle_collision(area)

func _on_LaserButton_pressed():
    if not game_map.input_enabled:
        return

    activate_state(state.LINE_WEAPON)

func _on_MissileButton_pressed():
    if not game_map.input_enabled:
        return

    activate_state(state.AREA_WEAPON)

func _on_MoveButton_pressed():
    if not game_map.input_enabled:
        return

    activate_state(state.MOVE)

func _on_ShieldButton_pressed():
    if not game_map.input_enabled:
        return

    activate_state(state.SHIELD)
