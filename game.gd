extends Node2D

# class member variables go here, for example:
var background = null
var camera_container = null
var camera = null
var lander = null

func _ready():
	background = get_node("background")
	camera = get_node("CameraContainer/Camera2D")
	camera_container = get_node("CameraContainer")
	lander = get_node("MoonLander")
	# do some initializing
	lander.set_rotation_degrees(90)

func _process(delta):
	# camera position synced to lander
	if lander.alive:
		camera_container.set_position(lander.get_position())
	# background positioning relative to camera
	var new_pos = camera.get_camera_screen_center() - (background.get_position()/2)
	background.set_position(new_pos)
