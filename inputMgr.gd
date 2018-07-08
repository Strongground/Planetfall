extends Node2D

# class member variables go here, for example:
onready var _game = get_tree().get_current_scene()
onready var lander = _game.find_node("MoonLander")
	
func _input(event):
	if Input.is_action_pressed("game_quit"):
		get_tree().change_scene("res://main_menu.tscn")
	if Input.is_action_pressed("contracts_screen"):
		_game.gui.show_contracts_screen()