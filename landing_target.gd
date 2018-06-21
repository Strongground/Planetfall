extends Node2D

# nodes
onready var _game = get_node("/root/Game")
onready var _lander = _game.get_node("MoonLander")
onready var _indicator = get_node("Indicator")
onready var _target_area = get_node("TargetArea")
onready var _gui = get_node("/root/Game/CameraContainer/GUI")
# members
export (String) var expected_delivery_good = "none"
export (int) var expected_goods_amount = 0

var show_message = 0

func _ready():
	pass

func _process(delta):
	if _target_area.overlaps_body(_game.lander) and _game.lander.alive and _game.lander.landed:
		if expected_delivery_good != "none" and expected_goods_amount > 0:
			if _lander.has_loaded(expected_delivery_good, expected_goods_amount):
				_lander.remove_from_inventory(expected_delivery_good, expected_goods_amount)
				if show_message != 1:
					print("Cargo of " + str(expected_goods_amount) + " " + str(globals.get_goods_name(expected_delivery_good)) + " unloaded!")
					show_message = 1
			else:
				if show_message != 1:
					print("You don't have the cargo to fulfill this contract!")
					show_message = 1
		# _gui.show_winner()