extends Sprite

var map_position: Vector2

enum actions {MOVE, ATTACK}

var planned_action

var planned_move_position

var game_map

func telegraph_action():
    planned_action = actions.ATTACK

    var tile_map = $Attacks

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
        pass
    elif planned_action == actions.ATTACK:
        $LaserBeam.play('Intro')


func _on_LaserBeam_animation_finished():
    $LaserBeam.play('Persist')
