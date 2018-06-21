extends Node2D

# nodes
onready var _game = get_node("/root/Game")
onready var _lander = _game.get_node("MoonLander")
onready var _indicator = get_node("Indicator")
onready var _target_area = get_node("TargetArea")
onready var _gui = get_node("/root/Game/CameraContainer/GUI")
# members
enum GOODS {  }
export (GOODS) var delivery_good = null
export (int) var goods_amount = 0

func _ready():
	pass
	
func _process(delta):
	if _target_area.overlaps_body(_game.lander) and _game.lander.alive and _game.lander.landed:
		_gui.show_winner()