extends MarginContainer

# class member variables go here, for example:
onready var _warning_light = get_node("Warning_Dot")
onready var _shine = get_node("Aura")
onready var _tween = get_node("Tween")
onready var _gcolor = null
onready var _gspeed = 0.0
onready var _gcurrent = Color(1,1,1,1)

func _ready():
	_tween.connect("tween_completed", self, "on_tween_completed")

func is_blinking():
	return _tween.is_active()

# Start to blink with the given color and speed. There are defaults
# for both parameters.
# @input color : Color
# @input (optional) speed : Float
func blink(color=Color(1,0,0,1), speed=1.0):
	_gcolor = color
	_gspeed = speed
	_gcurrent = _warning_light.get_modulate()
	_tween.interpolate_property(_warning_light, "modulate", _gcurrent, _gcolor, _gspeed, Tween.TRANS_LINEAR, Tween.EASE_IN)
	_tween.set_repeat(true)
	_tween.start()