extends Node2D

var current_turn = 0

var laser_enemy_scene = preload('res://scenes/LaserEnemy.tscn')
var bomb_enemy_scene = preload('res://scenes/BombEnemy.tscn')
var trash_talking_enemy_scene = preload('res://scenes/TrashTalkingEnemy.tscn')

onready var game_map = $GameMap
onready var title_ui = $UIs/Title
onready var map_ui = $UIs/MapUI
onready var battery = $UIs/MapUI/Battery
onready var turn_label = $UIs/MapUI/TurnLabel
onready var game_over_ui = $UIs/GameOver
onready var game_over_ui_turn_text = $UIs/GameOver/TurnText

enum turn {ENEMY_SPAWN, ENEMY_TELEGRAPH, HERO, ENEMY_ACTION}
var whose_turn = turn.ENEMY_SPAWN

var active_enemy_index = 0
var enemies_turn_order

func _ready():
    randomize()
    self.set_physics_process(false)

    $UIs/Title.visible = true
    $UIs/GameOver.visible = false
    $UIs/MapUI.visible = false
    $Grid.visible = false
    $GameMap.visible = false

    $BGM.play()

    title_ui.get_node('PlayButton').connect('pressed', self, 'reset_game')

    map_ui.get_node('Buttons/LaserButton').connect('pressed', game_map.hero, '_on_LaserButton_pressed')
    map_ui.get_node('Buttons/MissileButton').connect('pressed', game_map.hero, '_on_MissileButton_pressed')
    map_ui.get_node('Buttons/MoveButton').connect('pressed', game_map.hero, '_on_MoveButton_pressed')
    map_ui.get_node('Buttons/ShieldButton').connect('pressed', game_map.hero, '_on_ShieldButton_pressed')

    game_over_ui.get_node('RestartButton').connect('pressed', self, 'reset_game')

    game_map.hero.connect('hero_died', self, '_on_Hero_died')
    game_map.hero.connect('energy_changed', self, '_on_Hero_energy_changed')
    game_map.hero.connect('potential_energy_use_changed', self, '_on_Hero_potential_energy_use_changed')

func reset_game():
    self.set_physics_process(true)

    current_turn = 0
    turn_label.text = 'Turn 1'

    game_over_ui.visible = false
    title_ui.visible = false
    map_ui.visible = true

    $Grid.visible = true
    $GameMap.visible = true

    game_map.move_hero(Vector2(7, 7))
    game_map.hero.reset()
    game_map.clear_enemies()
    game_map.clear_pickups()

    battery.set_energy(game_map.hero.starting_energy)

    whose_turn = turn.ENEMY_SPAWN
    active_enemy_index = 0

func _physics_process(delta):
    if whose_turn == turn.ENEMY_SPAWN:
        spawn_enemies()
        whose_turn = turn.ENEMY_TELEGRAPH
        enemies_turn_order = game_map.enemies.values()
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

        active_enemy.start_telegraph_turn(current_turn)
    elif whose_turn == turn.HERO:
        var hero = game_map.hero

        if hero.playing_turn:
            return

        if hero.just_finished_turn:
            hero.just_finished_turn = false
            hero.really_finished_turn = true
            return

        if hero.energy <= 0 or not hero.is_alive or hero.really_finished_turn:
            hero.really_finished_turn = false
            hero.handle_collisions()
            game_map.set_input_enabled(false)
            whose_turn = turn.ENEMY_ACTION
            enemies_turn_order = game_map.enemies.values()
            return

        # Let the player take their turn.
        hero.playing_turn = true
        game_map.set_input_enabled(true)

    elif whose_turn == turn.ENEMY_ACTION:
        if active_enemy_index >= len(enemies_turn_order):
            active_enemy_index = 0
            whose_turn = turn.ENEMY_SPAWN
            current_turn += 1
            turn_label.text = 'Turn %s' % (current_turn + 1)
            return

        var active_enemy = enemies_turn_order[active_enemy_index]
        if not is_instance_valid(active_enemy):
            active_enemy_index += 1
            return

        if active_enemy.just_finished_turn:
            active_enemy_index += 1
            active_enemy.just_finished_turn = false
            return

        if active_enemy.playing_turn:
            return

        active_enemy.start_action_turn()

func _on_Hero_died():
    game_map.set_input_enabled(false)
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
    var desired_enemies = (current_turn+10)/10 + 2
    print('Turn number %s, desired enemies %s, current enemies %s' % [current_turn, desired_enemies, num_enemies])
    print('Enemies to spawn: ', max(desired_enemies - num_enemies, 0))
    for i in max(desired_enemies - num_enemies, 0):
        var percent = randi() % 100
        var enemy
        if percent < 20:
            enemy = trash_talking_enemy_scene.instance()
        elif percent < 70:
            enemy = laser_enemy_scene.instance()
        else:
            enemy = bomb_enemy_scene.instance()
        var empty_cells = game_map.get_empty_cells()
        game_map.place_enemy(enemy, empty_cells.keys()[randi() % len(empty_cells)])


func _on_GameMap_input_enabled(enabled):
    for button in map_ui.get_node('Buttons').get_children():
        button.disabled = not enabled
