extends Node2D

var turn = 0

var enemy_scene = preload('res://Enemy.tscn')

onready var game_map = $GameMap
onready var map_ui = $MapUI
onready var energy_resource = $MapUI/TextureProgress

var bar_low = preload("res://energy_inner_low.png")
var bar_med = preload("res://energy_inner_med.png")
var bar_high = preload("res://energy_inner_high.png")

func _ready():
    game_map.spawn_hero(Vector2(7, 7))

    game_map.hero.connect('move_finished', self, '_on_Player_move_finished')

    energy_resource.min_value = 0
    energy_resource.max_value = game_map.hero.energy
    energy_resource.texture_progress = bar_high

    spawn_enemies()
    enemies_telegraph_actions()

    game_map.input_enabled = true

func _on_Player_move_finished():
    game_map.input_enabled = false
    enemies_do_actions()
    turn += 1
    spawn_enemies()
    enemies_telegraph_actions()
    game_map.input_enabled = true

func spawn_enemies():
    if turn == 0:
        var enemy = enemy_scene.instance()
        game_map.place_enemy(enemy, Vector2(7, 2))

        enemy = enemy_scene.instance()
        game_map.place_enemy(enemy, Vector2(9, 5))
    else:
        var num_enemies = len(game_map.enemies)
        var desired_enemies = (turn+10)/10
        print('Turn number %s, desired enemies %s, current enemies %s' % [turn, desired_enemies, num_enemies])

func enemies_telegraph_actions():
    for enemy in game_map.enemies.values():
        enemy.telegraph_action()

func enemies_do_actions():
    for enemy in game_map.enemies.values():
        enemy.do_action()

var low_pct = 0.4
var med_pct = 0.7

func _process(delta):
    energy_resource.value = game_map.hero.energy
    energy_resource.texture_progress = bar_high
    if energy_resource.value < energy_resource.max_value * med_pct and \
        energy_resource.value >= energy_resource.max_value * low_pct:
        energy_resource.texture_progress = bar_med
    elif energy_resource.value < energy_resource.max_value * low_pct:
        energy_resource.texture_progress = bar_low
