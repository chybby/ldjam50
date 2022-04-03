extends Node2D

var turn = 0

var enemy_scene = preload('res://Enemy.tscn')

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
    
    energy_resource.min_value = 0
    energy_resource.max_value = game_map.hero.starting_energy
    game_map.hero.energy = game_map.hero.starting_energy
    energy_resource.value = game_map.hero.starting_energy

    game_map.hero.connect('move_finished', self, '_on_Player_move_finished')

    spawn_enemies()
    enemies_telegraph_actions()

    game_map.input_enabled = true    

func _on_Player_move_finished():
    energy_resource.value = game_map.hero.energy
    game_map.input_enabled = false
    # check if it's game over
    if energy_resource.value <= 0:
        map_ui.visible = false
        game_over_ui_turn_text.text = "You lasted " + str(turn) + " turns"
        game_over_ui.visible = true
        return
        
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
