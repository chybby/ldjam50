extends Node2D

var map_position: Vector2

enum action {MOVE, ATTACK, NOTHING}

onready var game_map = get_parent()

var pickup_scene = preload('res://Pickup.tscn')

var previous_action
var planned_action

var playing_turn = false
var just_finished_turn = false

func start_telegraph_turn(turn):
    playing_turn = true
    var result = telegraph_action(turn)
    if result is GDScriptFunctionState:
        yield(result, 'completed')
    playing_turn = false
    just_finished_turn = true

func telegraph_action(turn):
    pass

func start_action_turn():
    playing_turn = true
    var result = do_action()
    if result is GDScriptFunctionState:
        yield(result, 'completed')
    playing_turn = false
    just_finished_turn = true

func do_action():
    pass

func prevents_movement():
    return true

func _on_Hitbox_area_entered(area):
    print('Enemy entered area: ', area)
    if area.get_collision_layer_bit(1):  # Weapons.
        var hero = area.get_parent().get_parent().get_parent()
        if hero != game_map.hero:
            return
        print('Enemy entered weapon area of hero: ', hero)
        game_map.remove_enemy(map_position)
        var pickup = pickup_scene.instance()
        game_map.place_pickup(pickup, map_position)
    elif area.get_collision_layer_bit(2):  # Pickups.
        var pickup = area.get_parent()
        print('Enemy entered area of pickup: ', pickup)
        # pickup.pickup_effect()
        pickup.queue_free()
