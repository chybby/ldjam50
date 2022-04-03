extends Sprite

var map_position: Vector2

enum actions {MOVE, ATTACK, NOTHING}

onready var game_map = get_parent()

var previous_action
var planned_action
var all_lasers = []
var active_lasers = []

func _ready():
    all_lasers.append($LaserBeamLeft)
    all_lasers.append($LaserBeamUp)
    all_lasers.append($LaserBeamRight)
    all_lasers.append($LaserBeamDown)

func telegraph_action():
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
    laser.play('Persist')

func play_laser_outro(laser):
    # Play the firing animation backwards.
    laser.play('Fire', true)
    yield(laser, 'animation_finished')
    laser.visible = false

#    var tile_map = $Attacks

#    var p = map_position
#    p.x = 0
#    while p.x < game_map.width:
#        if p != map_position:
#            planned_attack_area.append(p)
#            tile_map.set_cell(p.x - map_position.x, p.y - map_position.y, 0, true, true, true)
#        p.x += 1
#
#    p = map_position
#    p.y = 0
#    while p.y < game_map.height:
#        if p != map_position:
#            planned_attack_area.append(p)
#            tile_map.set_cell(p.x - map_position.x, p.y - map_position.y, 0)
#        p.y += 1

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
