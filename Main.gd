extends Node2D

var turn = 0

var laser_enemy_scene = preload('res://LaserEnemy.tscn')
var bomb_enemy_scene = preload('res://BombEnemy.tscn')

onready var game_map = $GameMap
onready var map_ui = $MapUI
onready var energy_resource = $MapUI/TextureProgress
onready var game_over_ui = $GameOver
onready var game_over_ui_turn_text = $GameOver/TurnText

func _ready():
    setup_game()

func setup_game():
    game_map.clear_enemies()
    turn = 0
    game_over_ui.visible = false
    map_ui.visible = true
    game_map.spawn_hero(Vector2(7, 7))
    game_map.hero.get_node('Sprite').rotation = 0
    game_map.hero.shield_angle = -PI/2
    game_map.hero.get_node('Shield').visible = true

    energy_resource.min_value = 0
    energy_resource.max_value = game_map.hero.starting_energy
    game_map.hero.energy = game_map.hero.starting_energy
    energy_resource.value = game_map.hero.starting_energy

    game_map.hero.connect('move_finished', self, '_on_Hero_move_finished')
    game_map.hero.connect('hero_died', self, '_on_Hero_died')
    game_map.hero.connect('energy_changed', self, '_on_Hero_energy_changed')

    # Special enemy setup for turn 1
    var enemy = laser_enemy_scene.instance()
    game_map.place_enemy(enemy, Vector2(7, 2))

    var result = enemies_telegraph_actions()
    if result is GDScriptFunctionState:
        yield(result, 'completed')

    game_map.input_enabled = true

func _on_Hero_move_finished():
    game_map.input_enabled = false

    var result = enemies_do_actions()
    if result is GDScriptFunctionState:
        yield(result, 'completed')
    turn += 1
    spawn_enemies()

    result = enemies_telegraph_actions()
    if result is GDScriptFunctionState:
        yield(result, 'completed')

    if game_map.hero.is_alive():
        game_map.input_enabled = true
    else:
        yield(get_tree(), 'idle_frame')
        _on_Hero_move_finished()

func _on_Hero_died():
    game_map.input_enabled = false
    map_ui.visible = false
    game_over_ui_turn_text.text = "You lasted " + str(turn) + " turns"
    game_over_ui.visible = true

func _on_Hero_energy_changed(energy):
    energy_resource.value = energy

func spawn_enemies():
    var num_enemies = len(game_map.enemies)
    var desired_enemies = (turn+10)/10
    print('Turn number %s, desired enemies %s, current enemies %s' % [turn, desired_enemies, num_enemies])
    print('Enemies to spawn: ', max(desired_enemies - num_enemies, 0))
    for i in max(desired_enemies - num_enemies, 0):
        var enemy = bomb_enemy_scene.instance()
        var empty_cells = game_map.get_empty_cells()
        game_map.place_enemy(enemy, empty_cells.keys()[randi() % len(empty_cells)])

func enemies_telegraph_actions():
    for enemy in game_map.enemies.values():
        var result = enemy.telegraph_action(turn)
        if result is GDScriptFunctionState:
            yield(result, 'completed')

func enemies_do_actions():
    for enemy in game_map.enemies.values():
        var result = enemy.do_action()
        if result is GDScriptFunctionState:
            yield(result, 'completed')
