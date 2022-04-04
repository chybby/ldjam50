extends TileMap

func _ready():
    var rect = get_used_rect()
    for x in rect.size.x:
        for y in rect.size.y:
            set_cell(x, y, get_cell(x, y), randi() % 2 == 0, randi() % 2 == 0, randi() % 2 == 0, get_cell_autotile_coord(x, y))
