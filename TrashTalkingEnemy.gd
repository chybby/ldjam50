extends "res://Enemy.gd"

var lines = [
    "You are stinky! :(",
    "You'll run out of battery eventually!",
    "Just give up, there's only one of you and and endless army of us!",
]

func telegraph_action(turn):
    if randi() % 2 == 0:
        planned_action = actions.MOVE
    else:
        planned_action = actions.NOTHING

func do_action():
    if 1:#randi() % 5 == 0:
        $SpeechBubble.position = Vector2(235, -39)
        $SpeechBubble.flip_h = false
        $SpeechBubble.flip_v = false
        if map_position.x > game_map.width/2:
            $SpeechBubble.position.x *= -1
            $SpeechBubble.position.x += 64
            $SpeechBubble.flip_h = true
        if map_position.y > game_map.height/2:
            $SpeechBubble.position.y *= -1
            $SpeechBubble.position.y += 64
            $SpeechBubble.flip_v = true
        $SpeechBubble/Label.text = lines[randi() % len(lines)]
        $SpeechBubble.visible = true
        $Timer.start()

    if planned_action == actions.MOVE:
        pass

func _on_Timer_timeout():
    $SpeechBubble.visible = false
