extends TileMap

var width = get_used_rect().size.x
var height = get_used_rect().size.y

var hovered_position = null

onready var hero = $Hero
var enemies = {}

func _ready():
    clear()

func draw_valid_moves(position, max_distance):
    var vms = get_valid_moves(position, max_distance)[1]
    for v in vms:
        hero.draw_valid_moves(vms)

func get_valid_moves(position, max_distance):
    # TODO: any need for < 0, > screen width check?
    var valid_moves = []
    var valid_moves_rel = []
    for x in range(-max_distance, max_distance+1):
        for y in range(-max_distance, max_distance+1):
            if x == 0 and y == 0:
                continue
            var newx = position.x+x
            var newy = position.y+y
            if newx < 0 or newy < 0 or newx >= width or newy >= height:
                continue
            valid_moves.append(Vector2(newx, newy))
            valid_moves_rel.append(Vector2(x, y))
    return [valid_moves, valid_moves_rel]

#func get_grid():
#    var grid = []
#    for x in width:
#        var row = []
#        for y in height:
#            row.append([])
#        grid.append(row)
#
#    grid[hero.map_position.x][hero.map_position.y].append(hero)
#
#    for enemy in enemies:
#        grid[enemy.map_position.x][enemy.map_position.y].append(enemy)

func spawn_hero(position):
    hero.map_position = position
    hero.position = map_to_world(position)

func move_hero(position):
    var valid_moves = get_valid_moves(hero.map_position, 1)[0]
    var is_valid = false
    for v in valid_moves:
        if position == v:
            is_valid = true
            break
    if not is_valid:
        return

    hero.map_position = position
    hero.position = map_to_world(position)

func place_enemy(enemy, position):
    enemies[position] = enemy
    enemy.map_position = position

    enemy.position = map_to_world(position)

func mouse_changed_cell(old_position, new_position):
    if old_position != null:
        set_cell(old_position.x, old_position.y, -1)

    if new_position != null:
        set_cell(new_position.x, new_position.y, 0)

func mouse_hover(position):
    if position == hovered_position:
        return

    var old_hovered_position = hovered_position
    hovered_position = position

    mouse_changed_cell(old_hovered_position, hovered_position)

func mouse_up():
    if hovered_position == null:
        return

func mouse_down():
    if hovered_position == null:
        return

func _process(delta):
    if hero.active_state == hero.STATE_NONE:
        hero.clear_valid_moves()
    if hero.active_state == hero.STATE_MOVE:
        draw_valid_moves(world_to_map(hero.position), 1)

func _input(event):
    if event is InputEventMouseButton:
        if event.pressed:
            if hero.active_state == hero.STATE_MOVE:
                move_hero(world_to_map(event.position))
                hero.active_state = hero.STATE_NONE
#    elif event is InputEventMouseMotion:
#        mouse_hover(game_map.world_to_map(event.position))

func _notification(event):
    if event == NOTIFICATION_WM_MOUSE_EXIT:
        mouse_hover(null)
