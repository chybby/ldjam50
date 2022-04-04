extends TileMap

signal cell_clicked(position)

var width = get_used_rect().size.x
var height = get_used_rect().size.y

onready var hero = $Hero
var enemies = {}
var pickups = {}

var input_enabled = false

func _ready():
    clear()

func get_valid_moves(current_position, max_distance):
    var valid_moves = []
    var valid_moves_rel = []
    for x in range(-max_distance, max_distance+1):
        for y in range(-max_distance, max_distance+1):
            if x == 0 and y == 0:
                continue
            var newx = current_position.x+x
            var newy = current_position.y+y
            var new_position = Vector2(newx, newy)
            if is_empty_space(new_position):
                valid_moves.append(new_position)
                valid_moves_rel.append(Vector2(x, y))
    return [valid_moves, valid_moves_rel]

func get_empty_cells():
    var cells = {}
    for x in width:
        for y in height:
            cells[Vector2(x, y)] = 1

    for enemy_position in enemies.keys():
        cells.erase(enemy_position)

    cells.erase(hero.map_position)

    return cells

func is_empty_space(position):
    if position.x < 0 or position.y < 0 or position.x >= width or position.y >= height:
        return false
    if enemies.has(position) and enemies[position].prevents_movement():
        return false
    if hero.map_position == position:
        return false
    return true

func is_valid_move(current_position, new_position, max_distance):
    var valid_moves = get_valid_moves(current_position, max_distance)[0]
    return new_position in valid_moves

func move_hero(new_position):
    hero.map_position = new_position
    hero.position = map_to_world(new_position)

func place_enemy(enemy, position):
    add_child(enemy)
    enemies[position] = enemy
    enemy.map_position = position

    enemy.position = map_to_world(position)

func clear_enemies():
    for enemy_position in enemies.keys():
        remove_enemy(enemy_position)

func remove_enemy(position):
    var enemy = enemies[position]
    enemies.erase(position)
    remove_child(enemy)

func move_enemy(enemy, new_position):
    enemies.erase(enemy.map_position)
    enemies[new_position] = enemy

    enemy.map_position = new_position
    enemy.position = map_to_world(new_position)

func place_pickup(pickup, position):
    add_child(pickup)
    pickups[position] = pickup
    pickup.map_position = position

    pickup.position = map_to_world(position)

func clear_pickups():
    for pickup_position in pickups.keys():
        remove_pickup(pickup_position)

func remove_pickup(position):
    var pickup = pickups[position]
    pickups.erase(position)
    remove_child(pickup)

func mouse_down(mouse_position):
    var map_position = world_to_map(mouse_position)
    if map_position.x < 0 or map_position.x >= width or map_position.y < 0 or map_position.y >= height:
        return
    input_enabled = false
    emit_signal('cell_clicked', map_position)

func _input(event):
    if not input_enabled:
        return

    if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
        if not event.pressed:
            mouse_down(event.position)
