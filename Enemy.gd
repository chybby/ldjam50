extends Sprite

var map_position: Vector2

enum actions {MOVE, ATTACK, NOTHING}

onready var game_map = get_parent()

var previous_action
var planned_action

func telegraph_action(turn):
    pass

func do_action():
    pass
