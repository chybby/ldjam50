extends Node2D

var turn = 0

var enemy_scene = preload('res://Enemy.tscn')

onready var game_map = $GameMap

func _ready():
    game_map.set_hero(Vector2(7, 7))

    spawn_enemies()
    enemies_telegraph_actions()

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

func do_enemy_turn():
    pass
