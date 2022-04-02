extends TileMap

var width = get_used_rect().size.x
var height = get_used_rect().size.y

var hovered_position = null

func _ready():
    clear()

#func draw_valid_moves(position, max_distance):
#    var cellv = world_to_map(position)
#    for x in range(-max_distance, max_distance):
#        for y in range(-max_distance, max_distance):
#            if x == 0 and y == 0:
#                continue
#            set_cell(cellv.x-x, cellv.y-y, )

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

func _input(event):
    if event is InputEventMouseButton:
        if event.pressed:
            mouse_down()
        else:
            mouse_up()
    elif event is InputEventMouseMotion:
        mouse_hover(world_to_map(event.position))

func _notification(event):
    if event == NOTIFICATION_WM_MOUSE_EXIT:
        mouse_hover(null)
