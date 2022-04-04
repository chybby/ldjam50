extends Node2D

var current_turn = 0

var laser_enemy_scene = preload('res://LaserEnemy.tscn')
var bomb_enemy_scene = preload('res://BombEnemy.tscn')
var trash_talking_enemy_scene = preload('res://TrashTalkingEnemy.tscn')

onready var game_map = $GameMap
onready var map_ui = $MapUI
onready var battery = $MapUI/Battery
onready var turn_label = $MapUI/TurnLabel
onready var game_over_ui = $GameOver
onready var game_over_ui_turn_text = $GameOver/TurnText

enum turn {ENEMY_SPAWN, ENEMY_TELEGRAPH, HERO, ENEMY_ACTION}
var whose_turn = turn.ENEMY_SPAWN

var active_enemy_index = 0
var enemies_turn_order

func _ready():
    game_map.hero.connect('hero_died', self, '_on_Hero_died')
    game_map.hero.connect('energy_changed', self, '_on_Hero_energy_changed')
    game_map.hero.connect('potential_energy_use_changed', self, '_on_Hero_potential_energy_use_changed')
    $Music.play()

    reset_game()

func reset_game():
    game_map.clear_enemies()
    current_turn = 0
    turn_label.text = 'Turn: 1'

    game_over_ui.visible = false
    map_ui.visible = true

    game_map.move_hero(Vector2(7, 7))
    game_map.hero.reset()

    battery.set_energy(10)

    whose_turn = turn.ENEMY_SPAWN
    active_enemy_index = 0

func _physics_process(delta):
    if whose_turn == turn.ENEMY_SPAWN:
        #print('Spawning enemies')
        spawn_enemies()
        whose_turn = turn.ENEMY_TELEGRAPH
        enemies_turn_order = game_map.enemies.values()
        #print('Enemy turn order: ', enemies_turn_order)
    elif whose_turn == turn.ENEMY_TELEGRAPH:
        if active_enemy_index >= len(enemies_turn_order):
            active_enemy_index = 0
            whose_turn = turn.HERO
            return

        var active_enemy = enemies_turn_order[active_enemy_index]
        if active_enemy.just_finished_turn:
            active_enemy_index += 1
            active_enemy.just_finished_turn = false
            return

        if active_enemy.playing_turn:
            return

        #print('Starting enemy telegraph')
        active_enemy.start_telegraph_turn(current_turn)
    elif whose_turn == turn.HERO:
        var hero = game_map.hero

        if hero.just_finished_turn:
            hero.just_finished_turn = false
            hero.really_finished_turn = true
            return

        if hero.energy <= 0 or not hero.is_alive or hero.really_finished_turn:
            hero.really_finished_turn = false
            hero.handle_collisions()
            game_map.input_enabled = false
            whose_turn = turn.ENEMY_ACTION
            enemies_turn_order = game_map.enemies.values()
            #print('Enemy turn order: ', enemies_turn_order)
            return

        if hero.playing_turn:
            return

        # Let the player take their turn.
        #print('Start hero turn')
        hero.playing_turn = true
        game_map.input_enabled = true

    elif whose_turn == turn.ENEMY_ACTION:
        if active_enemy_index >= len(game_map.enemies):
            active_enemy_index = 0
            whose_turn = turn.ENEMY_SPAWN
            current_turn += 1
            turn_label.text = 'Turn: %s' % (current_turn + 1)
            return

        var active_enemy = enemies_turn_order[active_enemy_index]
        if active_enemy.just_finished_turn:
            active_enemy_index += 1
            active_enemy.just_finished_turn = false
            return

        if active_enemy.playing_turn:
            return

        #print('Starting enemy action')
        active_enemy.start_action_turn()

func _on_Hero_died():
    game_map.input_enabled = false
    map_ui.visible = false
    game_over_ui_turn_text.text = "You lasted %s turns" % (current_turn + 1)
    game_over_ui.visible = true

func _on_Hero_energy_changed(new_energy):
    battery.set_energy(new_energy)

func _on_Hero_potential_energy_use_changed(new_potential_energy_use):
    battery.show_potential_energy_usage(new_potential_energy_use)

func spawn_enemies():
    if current_turn == 0:
        # Special enemy setup for turn 1
        var enemy = laser_enemy_scene.instance()
        game_map.place_enemy(enemy, Vector2(7, 2))
        return

    var num_enemies = len(game_map.enemies)
    var desired_enemies = (current_turn+10)/10
    print('Turn number %s, desired enemies %s, current enemies %s' % [current_turn, desired_enemies, num_enemies])
    print('Enemies to spawn: ', max(desired_enemies - num_enemies, 0))
    for i in max(desired_enemies - num_enemies, 0):
        var enemy = trash_talking_enemy_scene.instance()
        var empty_cells = game_map.get_empty_cells()
        game_map.place_enemy(enemy, empty_cells.keys()[randi() % len(empty_cells)])
