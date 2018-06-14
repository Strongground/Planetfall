extends Node2D

onready var _game = get_node("/root/Game")
onready var _indicator = get_node("Indicator")
onready var _target_area = get_node("TargetArea")
onready var _gui = get_node("/root/Game/CameraContainer/GUI")

func _ready():
	pass
	
func _process(delta):
	if _target_area.overlaps_body(_game.lander) and _game.lander.alive and _game.lander.landed:
		_gui.show_winner()

func _on_TargetArea_area_entered(area):
	print("Something entered the area: " + str(area))
	_indicator.set_visible(false)
