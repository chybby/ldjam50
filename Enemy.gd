extends Sprite

var map_position: Vector2

enum actions {MOVE, ATTACK, NOTHING}

onready var game_map = get_parent()

var planned_action

func _ready():
    game_map.hero.connect('move_finished', self, '_on_Player_move_finished')


func _on_Player_move_finished():
    if $LaserBeam.animation == 'Persist':
        $LaserBeam.visible = false

func telegraph_action():
    if planned_action == actions.ATTACK:
        if randi() % 2 == 0:
            planned_action = actions.MOVE
        else:
            planned_action = actions.NOTHING
    else:
        if randi() % 2 == 0:
            planned_action = actions.MOVE
        else:
            planned_action = actions.ATTACK
            $LaserBeam.visible = true
            $LaserBeam.play('Intro')

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
    if planned_action == actions.MOVE:
        var vms = game_map.get_valid_moves(map_position, 1)[0]
        var next_pos = vms[randi() % vms.size()]
        game_map.move_enemy(self, next_pos)
    elif planned_action == actions.ATTACK:
        $LaserBeam.play('Fire')

func _on_LaserBeam_animation_finished():
    if $LaserBeam.animation == 'Fire':
        $LaserBeam.play('Persist')
    elif $LaserBeam.animation == 'Intro':
        $LaserBeam.play('Telegraph')
