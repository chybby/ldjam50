extends Node2D

var turn = 0

var enemy_scene = preload('res://Enemy.tscn')

onready var game_map = $GameMap

func _ready():
    game_map.move_hero(Vector2(7, 7))

    spawn_enemies()
    enemies_plan_moves()

    # Hero's turn

func spawn_enemies():
    var enemy = enemy_scene.instance()
    add_child(enemy)
    game_map.place_enemy(enemy, Vector2(7, 2))

func enemies_plan_moves():
    for enemy in game_map.enemies.values():
        enemy.plan_move()

func do_enemy_turn():
    pass
