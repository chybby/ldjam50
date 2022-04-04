extends "res://Enemy.gd"

var lines = [
    "You are stinky! :(",
    "You'll run out of battery eventually!",
    "Just give up, there's only one of you and and endless army of us!",
]

func telegraph_action(turn):
    if randi() % 2 == 0:
        planned_action = action.MOVE
    else:
        planned_action = action.NOTHING

func do_action():
    if randi() % 5 == 0:
        $SpeechBubble.position = Vector2(235, -39)
        $SpeechBubble.flip_h = false
        $SpeechBubble.flip_v = false
        if map_position.x > game_map.width/2:
            $SpeechBubble.position.x *= -1
            $SpeechBubble.position.x += 64
            $SpeechBubble.flip_h = true
        if map_position.y < game_map.height/2:
            $SpeechBubble.position.y *= -1
            $SpeechBubble.position.y += 64
            $SpeechBubble.flip_v = true
        $SpeechBubble/Label.text = lines[randi() % len(lines)]
        $SpeechBubble.visible = true
        $Timer.start()

    if planned_action == action.MOVE:
        var vms = game_map.get_valid_moves(map_position, 1)[0]
        if len(vms) == 0:
            return
        var next_pos = vms[randi() % vms.size()]

        var tween = $Tween
        tween.interpolate_property(self, "position",
                position, game_map.map_to_world(next_pos), 1,
                Tween.TRANS_QUINT, Tween.EASE_IN_OUT)
        tween.start()
        yield(tween, 'tween_completed')

        game_map.move_enemy(self, next_pos)

func _on_Timer_timeout():
    $SpeechBubble.visible = false
