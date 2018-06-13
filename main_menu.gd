extends Control

func _ready():
	set_size(get_viewport().get_size())
	print(get_size())

func _on_Exit_pressed():
	get_tree().quit()

func _on_NewGame_pressed():
	get_tree().change_scene("res://test_level.tscn")
