extends "res://Enemy.gd"

var explosion_countdown = 3

func telegraph_action(turn):
    # TODO: show countdown on sprite
    pass

func do_action():
    if explosion_countdown == 0:
        $Sprite.visible = false
        $Emp.visible = true
        $Emp.play('Intro')
        yield($Emp, 'animation_finished')
        $Area2D/CollisionShape2D.disabled = false
        $Emp.play('Persist')
    elif explosion_countdown == -1:
        game_map.remove_enemy(map_position)
        queue_free()
    explosion_countdown -= 1
