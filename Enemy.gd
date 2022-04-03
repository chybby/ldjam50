extends Sprite

var map_position: Vector2

enum actions {MOVE, ATTACK}

var planned_action

var planned_attack_area = []
var planned_move_position

var game_map

func next_action():
    # choose a random spot to move to
    var vms = game_map.get_valid_moves(map_position, 1)[0]
    var next_pos = vms[randi() % vms.size()]
    map_position = next_pos

func telegraph_action():
    planned_action = actions.ATTACK

    var tile_map = $PlannedAttacks

    var p = map_position
    p.x = 0
    while p.x < game_map.width:
        if p != map_position:
            planned_attack_area.append(p)
            tile_map.set_cell(p.x - map_position.x, p.y - map_position.y, 0, true, true, true)
        p.x += 1

    p = map_position
    p.y = 0
    while p.y < game_map.height:
        if p != map_position:
            planned_attack_area.append(p)
            tile_map.set_cell(p.x - map_position.x, p.y - map_position.y, 0)
        p.y += 1
