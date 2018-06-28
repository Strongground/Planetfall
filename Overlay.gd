extends RichTextLabel

onready var _tween = get_node("Tween")
onready var _timer = get_node("Timer")
var _start_modulation = null
var _target_modulation = null
var _speed = null
var _counter = 0

func _ready():
	_start_modulation = self.get_modulate()

func show(_text, target_modulation=Color(1,1,1,1), speed=1.0):
	_counter = 0
	self.set_text(str(_text))
	_target_modulation = target_modulation
	_speed = speed
	_tween.interpolate_property(self, "modulate", _start_modulation, _target_modulation, _speed, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	_tween.start()
	_counter += 1

func _on_Tween_tween_completed(object, key):
	if _counter == 1:
		_tween.interpolate_property(self, "modulate", _target_modulation, _start_modulation, _speed, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		_tween.start()
		_counter += 1
	else:
		_tween.remove_all()