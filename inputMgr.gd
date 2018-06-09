extends Node2D

# class member variables go here, for example:
var game = null
var lander = null

func _ready():
	set_process_input(true)
	game = get_tree().get_current_scene()
	lander = game.find_node("MoonLander")
	print(lander)

func _process(delta):
	pass
	
func _input(event):
	if Input.is_action_pressed("game_quit"):
		get_tree().quit()