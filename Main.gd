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
    game_map.set_hero(Vector2(7, 7))
    energy_resource.min_value = 0
    energy_resource.max_value = game_map.hero.energy
    energy_resource.texture_progress = bar_high
    spawn_enemies()
#    enemies_telegraph_actions()

    # Hero's turn

func spawn_enemies():
    var enemy = enemy_scene.instance()
    enemy.game_map = game_map
    add_child(enemy)
    game_map.place_enemy(enemy, Vector2(7, 2))

    enemy = enemy_scene.instance()
    enemy.game_map = game_map
    add_child(enemy)
    game_map.place_enemy(enemy, Vector2(9, 5))

func enemies_telegraph_actions():
    for enemy in game_map.enemies.values():
        enemy.telegraph_action()

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

func do_enemy_turn():
    pass
