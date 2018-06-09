extends Node2D

# class member variables go here, for example:
var background = null
var camera = null
var lander = null

func _ready():
	background = get_node("background")
	camera = get_node("MoonLander/Camera2D")
	lander = get_node("MoonLander")
	# do some initializing
	lander.set_rotation_degrees(90)

func _process(delta):
	var new_pos = camera.get_camera_screen_center() - (background.get_position()/2)
	background.set_position(new_pos)