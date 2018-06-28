extends Node2D

onready var _label = get_node("Label")
onready var _tween = get_node("Tween")
onready var _timer = get_node("Timer")
var _counter = 0

func _ready():
	pass
#	self.start("Default Text")
	
func start(text, object):
	_tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1), 2, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	_tween.interpolate_property(self, "position", Vector2(0,0), Vector2(0,-50), 2, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	_label.set_text(str(text))
	# Set position and pivot offset and rotation
	_label.set_pivot_offset(_label.get_size()/2)
	var _own_global_position = Vector2(object.get_global_position().x-_label.get_size().x/2,object.get_global_position().y)
	_label.set_global_position(_own_global_position)
	# Continue
	_timer.set_wait_time(text.length()/10)
	_counter += 1
	_tween.start()

func _on_tween_completed(object, key):
	_timer.start()

func _on_Timer_finished():
	if _counter == 1:
		_tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), 1, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		_tween.interpolate_property(self, "position", Vector2(0,-50), Vector2(0,-75), 1, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		_tween.start()
		_counter += 1
	else:
		_tween.remove_all()
		self.queue_free()
	
