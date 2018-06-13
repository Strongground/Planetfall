extends Node2D

var main_menu = null
var level_menu = null

func _ready():
	main_menu = get_node("MainMenu")
	level_menu = get_node("LevelSelection")

func _on_Exit_pressed():
	get_tree().quit()

func _on_NewGame_pressed():
	main_menu.set_visible(false)
	level_menu.set_visible(true)

func _on_TestLevel_pressed():
	get_tree().change_scene("res://test_level.tscn")

func _on_Back_pressed():
	main_menu.set_visible(true)
	level_menu.set_visible(false)