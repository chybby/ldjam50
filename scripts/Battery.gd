extends TextureRect

export(Color, RGB) var high_color

export var low_threshold = 2
export(Color, RGB) var low_color

export var med_threshold = 5
export(Color, RGB) var med_color

var segments

var energy = 10

func _ready():
    segments = $BatterySegments.get_children()

func set_energy(value):
    value = min(value, 10)
    value = max(value, 0)

    energy = value

    var segment_color = high_color

    if value <= low_threshold:
        segment_color = low_color
    elif value <= med_threshold:
        segment_color = med_color

    for segment in segments:
        segment.color = segment_color

    var i = 1
    for segment in segments:
        if i <= value:
            segment.visible = true
        else:
            segment.visible = false
        i += 1

    if value <= 0:
        $EmptyIndicator.visible = true
        $Timer.start()
    else:
        $EmptyIndicator.visible = false
        $Timer.stop()

func show_potential_energy_usage(value):
    for segment in segments:
        segment.color.a = 1

    for i in value:
        var segment_index = energy-1-i
        if segment_index >= 0:
            segments[segment_index].color.a = 0.5


func _on_Timer_timeout():
    $EmptyIndicator.visible = not $EmptyIndicator.visible
