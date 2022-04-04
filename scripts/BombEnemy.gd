extends "res://scripts/Enemy.gd"

var explosion_countdown = 3

func telegraph_action(turn):
    # TODO: show countdown on sprite
    pass

func do_action():
    if explosion_countdown == 3:
        $Sprite.play('One')
    elif explosion_countdown == 2:
        $Sprite.play('Two')
    elif explosion_countdown == 1:
        $Sprite.play('Three')
    elif explosion_countdown == 0:
        $Sprite.visible = false
        $Hitbox/CollisionShape2D.disabled = true
        $Emp.visible = true
        $Emp.play('Intro')
        yield($Emp, 'animation_finished')
        $Emp/Area2D/CollisionShape2D.disabled = false
        $Emp.play('Persist')
    elif explosion_countdown == -1:
        $Emp.play('Intro', true)
        yield($Emp, 'animation_finished')
        game_map.remove_enemy(map_position)
    explosion_countdown -= 1

func prevents_movement():
    return explosion_countdown > -1
