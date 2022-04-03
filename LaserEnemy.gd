extends "res://Enemy.gd"

var all_lasers = []
var active_lasers = []

func _ready():
    all_lasers.append($LaserBeamLeft)
    all_lasers.append($LaserBeamUp)
    all_lasers.append($LaserBeamRight)
    all_lasers.append($LaserBeamDown)

func telegraph_action(turn):
    if turn == 0:
        planned_action = actions.ATTACK
        var laser = $LaserBeamDown
        active_lasers.append(laser)
        yield(play_laser_telegraph(laser), 'completed')
        return

    if previous_action == actions.ATTACK:
        if randi() % 2 == 0:
            planned_action = actions.MOVE
        else:
            planned_action = actions.NOTHING
    else:
        var random = randi() % 3
        if random == 0:
            planned_action = actions.MOVE
        elif random == 1:
            planned_action = actions.ATTACK
            active_lasers.clear()
            for laser in all_lasers:
                if randi() % 2 == 0:
                    active_lasers.append(laser)

            var results = []
            for laser in active_lasers:
                results.append(play_laser_telegraph(laser))

            for result in results:
                if result.is_valid():
                    yield(result, 'completed')
        elif random == 2:
            planned_action = actions.NOTHING

func play_laser_telegraph(laser):
    laser.visible = true
    laser.play('Intro')
    yield(laser, 'animation_finished')
    laser.play('Telegraph')

func play_laser_fire(laser):
    laser.play('Fire')
    yield(laser, 'animation_finished')
    laser.get_node('Area2D/CollisionShape2D').disabled = false
    laser.play('Persist')

func play_laser_outro(laser):
    # Play the firing animation backwards.
    laser.play('Fire', true)
    yield(laser, 'animation_finished')
    laser.get_node('Area2D/CollisionShape2D').disabled = true
    laser.visible = false

func do_action():
    if previous_action == actions.ATTACK:
        var results = []
        for laser in active_lasers:
            results.append(play_laser_outro(laser))

        for result in results:
            if result.is_valid():
                yield(result, 'completed')

    if planned_action == actions.MOVE:
        var vms = game_map.get_valid_moves(map_position, 1)[0]
        var next_pos = vms[randi() % vms.size()]
        game_map.move_enemy(self, next_pos)
    elif planned_action == actions.ATTACK:
        var results = []
        for laser in active_lasers:
            results.append(play_laser_fire(laser))

        for result in results:
            if result.is_valid():
                yield(result, 'completed')
    previous_action = planned_action
