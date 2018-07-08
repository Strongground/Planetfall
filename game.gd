extends Node2D

# private members filled on _ready
onready var _background = get_node("background")
onready var _camera_container = get_node("CameraContainer")
onready var _camera = get_node("CameraContainer/Camera2D")
onready var _contract = preload("res://contract.tscn")
onready var floater = preload("res://floater.tscn")
onready var lander = get_node("MoonLander")
onready var gui = get_node("CameraContainer/GUI")
# private members
var _landing_targets = []

func _ready():
	# Do some necessary initialization
	lander.set_rotation_degrees(90)
	self._enumerate_landing_targets()
	self._create_random_contracts(5)
	# Do debug inits (cheats)
#	lander.add_to_inventory('food', 5)
#	self._create_contract("Food Delivery", 800, "food", 5, "farm", "grocery", "test")
	lander.accept_contract("test_food")
#	lander.fuel = 1200
#	lander.rc_fuel = 350
#	lander.add_credits(1000)

func _process(delta):
	# camera position synced to lander
	if lander.alive:
		_camera_container.set_position(lander.get_position())
	# background positioning relative to camera
	var new_pos = _camera.get_camera_screen_center() - (_background.get_position()/2)
	_background.set_position(new_pos)
	
func _enumerate_landing_targets():
	for landing_target in get_tree().get_nodes_in_group("landing_targets"):
		self._landing_targets.push_back(landing_target)

func get_landing_target(landing_target_id):
	for _landing_target in self._landing_targets:
		if _landing_target.get('id') == landing_target_id:
			return _landing_target
	return null

#/**
# * Creates a contract with the given parameters.
# * @input title : String
# * @input pay : Integer 
# * @input goods : String
# * @input goods_amount : Integer
# * @input origin_id : String
# * @input target_id : String
# * @input id : String
func _create_contract(title, pay, goods, goods_amount, origin_id, target_id, id=""):
	var new_contract = _contract.instance()
	new_contract.title = str(title)
	new_contract.pay = pay
	new_contract.goods = goods
	new_contract.goods_amount = goods_amount
	new_contract.origin_id = origin_id
	new_contract.target_id = target_id
	self.add_child(new_contract)
	
func _create_random_contracts(amount):
	for i in amount:
		# Reset randomness generator
		randomize()
		# Pick random good and amount of goods from global list of goods
		var random_good = globals.goods[globals.goods.keys()[randi()%globals.goods.size()]]
		var random_amount = randi() % (lander.get('inventory_space') + 1) + 1
		var good_price = random_good['price']
		var max_value = good_price * random_amount
		var random_pay = randi() % max_value + (max_value / 2)
		var random_origin = self._landing_targets[randi() % self._landing_targets.size()].get('id')
		var random_target = null
		randomize()
		while random_origin == random_target or random_target == null:
			random_target = self._landing_targets[randi() % self._landing_targets.size()].get('id')
		_create_contract(null, random_pay, random_good, random_amount, random_origin, random_target)

func _contract_exists(contract_id):
	return self.has_node(contract_id)

func get_contract(contract_id):
	if _contract_exists(contract_id):
		return get_node(contract_id)

func create_floater(text, parent=lander):
	var new_floater = floater.instance()
	self.add_child(new_floater)
	new_floater.start(text, parent)