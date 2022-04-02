extends TileMap

func _ready():
	var rect = get_used_rect()
	var tile_ids = tile_set.get_tiles_ids()
	var num_tiles = len(tile_ids)
	print(rect)
	for x in rect.size.x:
		for y in rect.size.y:
			set_cell(x, y, tile_ids[randi() % num_tiles], randi() % 2 == 0, randi() % 2 == 0)
