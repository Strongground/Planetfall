extends Node2D

# class member variables go here, for example:
var _background = null
var _camera_container = null
var _camera = null
var lander = null
var gui = null

func _ready():
	_background = get_node("background")
	_camera_container = get_node("CameraContainer")
	_camera = get_node("CameraContainer/Camera2D")
	lander = get_node("MoonLander")
	gui = get_node("CameraContainer/Camera2D/GUI")
	# do some initializing
	lander.set_rotation_degrees(90)

func _process(delta):
	# camera position synced to lander
	if lander.alive:
		_camera_container.set_position(lander.get_position())
	# background positioning relative to camera
	var new_pos = _camera.get_camera_screen_center() - (_background.get_position()/2)
	_background.set_position(new_pos)
