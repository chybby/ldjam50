extends TileMap

signal cell_clicked(position)

var width = get_used_rect().size.x
var height = get_used_rect().size.y

onready var hero = $Hero
var enemies = {}

var input_enabled = false

func _ready():
    clear()

func get_valid_moves(position, max_distance):
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
    add_child(enemy)
    enemies[position] = enemy
    enemy.map_position = position

    enemy.position = map_to_world(position)

func move_enemy(enemy, position):
    enemies.erase(enemy.map_position)
    enemies[position] = enemy

    enemy.map_position = position
    enemy.position = map_to_world(position)

func mouse_down(mouse_position):
    print('GameMap registered click at map position ', world_to_map(mouse_position))
    emit_signal('cell_clicked', world_to_map(mouse_position))

func _input(event):
    if not input_enabled:
        return

    if event is InputEventMouseButton:
        if not event.pressed:
            mouse_down(event.position)
