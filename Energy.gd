extends TextureProgress

var bar_low = preload("res://energy_inner_low.png")
var bar_med = preload("res://energy_inner_med.png")
var bar_high = preload("res://energy_inner_high.png")

var low_pct = 0.4
var med_pct = 0.7

# Called when the node enters the scene tree for the first time.
func _ready():
    texture_progress = bar_high

func _on_TextureProgress_value_changed(value):
    $Label.text = str(value)
    texture_progress = bar_high
    if value < max_value * med_pct and \
        value >= max_value * low_pct:
        texture_progress = bar_med
    elif value < max_value * low_pct:
        texture_progress = bar_low
