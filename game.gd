extends Node2D

# class member variables go here, for example:
onready var _background = get_node("background")
onready var _camera_container = get_node("CameraContainer")
onready var _camera = get_node("CameraContainer/Camera2D")
onready var lander = get_node("MoonLander")
onready var gui = get_node("CameraContainer/Camera2D/GUI")

func _ready():
	lander.set_rotation_degrees(90)
	lander.add_to_inventory('food', 4)

func _process(delta):
	# camera position synced to lander
	if lander.alive:
		_camera_container.set_position(lander.get_position())
	# background positioning relative to camera
	var new_pos = _camera.get_camera_screen_center() - (_background.get_position()/2)
	_background.set_position(new_pos)
