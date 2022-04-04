extends Button

func _on_Button_button_up():
    get_tree().get_root().get_node("Game").reset_game()
