extends Node2D

# class member variables go here, for example:
onready var _background = get_node("background")
onready var _camera_container = get_node("CameraContainer")
onready var _camera = get_node("CameraContainer/Camera2D")
onready var _contract = preload("res://contract.tscn")
onready var floater = preload("res://floater.tscn")
onready var lander = get_node("MoonLander")
onready var gui = get_node("CameraContainer/GUI")

func _ready():
	lander.set_rotation_degrees(90)
#	lander.add_to_inventory('food', 5)
#	self._create_contract("Food Delivery", 800, "food", 5, "farm", "grocery", "test")
	lander.accept_contract("test_food")
	lander.fuel = 1200
	lander.rc_fuel = 350
	lander.add_credits(1000)

func _process(delta):
	# camera position synced to lander
	if lander.alive:
		_camera_container.set_position(lander.get_position())
	# background positioning relative to camera
	var new_pos = _camera.get_camera_screen_center() - (_background.get_position()/2)
	_background.set_position(new_pos)

func _create_contract(title, pay, goods, goods_amount, origin_id, target_id, id=""):
	var new_contract = _contract.instance()
	new_contract.title = str(title)
	new_contract.pay = pay
	new_contract.goods = goods
	new_contract.goods_amount = goods_amount
	new_contract.origin_id = origin_id
	new_contract.target_id = target_id
	if id != "":
		new_contract.id = id
	else:
		new_contract.generate_id()
	self.add_child(new_contract)

func _contract_exists(contract_id):
	return self.has_node(contract_id)

func get_contract(contract_id):
	if _contract_exists(contract_id):
		return get_node(contract_id)

func get_landing_target(landing_target_id):
	for landing_target in get_tree().get_nodes_in_group("landing_targets"):
		if landing_target.get("id") == landing_target_id:
			return landing_target
	return null

func create_floater(text, parent=lander):
	var new_floater = floater.instance()
	self.add_child(new_floater)
	new_floater.start(text, parent)