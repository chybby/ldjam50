extends Node2D

var map_position

onready var game_map = get_parent()

export var energy_restored = 5

func pickup_effect():
    game_map.hero.use_energy(-energy_restored)
