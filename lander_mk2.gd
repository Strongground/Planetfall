extends RigidBody2D

# public members
export (int) var main_engine_thrust = 80
export (bool) var active = false
export (int) var rc_thrust = 100
export (float) var fuel_capacity = 200
export (float) var rc_fuel_capacity = 50
export (float) var damage_treshhold = 10
export (int) var inventory_space = 5
export (int) var credits_balance = 100

# private members
onready var _game = get_tree().get_current_scene()
onready var _camera = _game.find_node("Camera2D")
onready var _engine_particles = get_node("EngineParticles")
onready var _rc_thruster_particles_right = get_node("RCThrusterParticles_Right")
onready var _rc_thruster_particles_left = get_node("RCThrusterParticles_Left")
onready var _raycast = get_node("RayCast2D")
onready var _explosion = load("res://explosion.tscn")
onready var _debris = load("res://lander_debris.tscn")
# ++++++++ Debug ++++++++
onready var _marker1 = _game.find_node("Marker_Debug")
onready var _label1 = _game.find_node("HOT_Debug")
onready var _label2 = _game.find_node("HOT_Debug2")
onready var _ray = _game.find_node("Ray")
# init
var _rotation_dir = 0
var _has_landed_for = 0
var _terrain_collision = Vector2(0,0)
var _double_rc = false
var thrust = Vector2()
var fuel = 0.0
var rc_fuel = 0.0
var alive = true
var landed = false
var height_over_terrain = 0.0
var inventory = {}
var inventory_weight = 0.0
var craft_weight = 0.0
var contracts = []

func _ready():
	# sign main engine thrust negative
	main_engine_thrust = main_engine_thrust * -1
	# set initial fuel to capacity
	fuel = fuel_capacity
	rc_fuel = rc_fuel_capacity
	craft_weight = get_weight() * 100

func _process(delta):
	if self.active:
		# Set physical weight of craft to craft weight plus inventory weight
		set_weight(craft_weight + inventory_weight)
		# If fuel is empty, switch thrust and effects off
		if fuel <= 0:
			_engine_particles.set_emitting(false)
			thrust = Vector2(0,0)
		if rc_fuel <= 0:
			_rc_thruster_particles_left.set_emitting(false)
			_rc_thruster_particles_right.set_emitting(false)
			_rotation_dir = 0
		# Calculate height over terrain
		_raycast.set_cast_to(Vector2(1000, 0))
		_raycast.set_global_rotation_degrees(90)
		_terrain_collision = _raycast.get_collision_point()
		height_over_terrain = _terrain_collision.distance_to(self.get_global_transform().get_origin()) - 10
		if height_over_terrain < 0:
			height_over_terrain = 0

func _integrate_forces(state):
	if self.active:
		if fuel <= 0:
			fuel = 0

		# Input for vehicle controls
		if Input.is_action_just_pressed("ui_up"):
			if fuel > 0:
				thrust = Vector2(main_engine_thrust,0)
				_engine_particles.set_emitting(true)
		if Input.is_action_just_released("ui_up"):
			thrust = Vector2(0,0)
			_engine_particles.set_emitting(false)

		if Input.is_action_just_pressed("ui_right"):
			if rc_fuel > 0:
				_rotation_dir += 1
				_rc_thruster_particles_right.set_emitting(true)
		if Input.is_action_just_released("ui_right"):
			_rotation_dir = 0
			_rc_thruster_particles_right.set_emitting(false)

		if Input.is_action_just_pressed("ui_left"):
			if rc_fuel > 0:
				_rotation_dir -= 1
				_rc_thruster_particles_left.set_emitting(true)
		if Input.is_action_just_released("ui_left"):
			_rotation_dir = 0
			_rc_thruster_particles_left.set_emitting(false)

		if Input.is_action_pressed("ui_left") && Input.is_action_pressed("ui_right"):
			if rc_fuel > 0:
				_double_rc == true

		# Landed Detection
		# print(str(abs(get_linear_velocity().x)) + ", " + str(abs(get_linear_velocity().y)))
		# print("Has landed: " + str(landed) + ", has landed for: " + str(_has_landed_for))
		if abs(get_linear_velocity().x) < 0.25 and abs(get_linear_velocity().y) < 0.25:
			if _has_landed_for <= 100:
				_has_landed_for += 1
			else:
				set_sleeping(true)
				self.landed = true
		else:
			_has_landed_for = 0
			self.landed = false

		# calc fuel usage
		if abs(thrust.x) > 0 and fuel > 0:
			fuel -= abs(thrust.x) / 100.0
		if abs(_rotation_dir) >= 1 and rc_fuel > 0:
			if _double_rc == true:
				rc_fuel -= rc_thrust / 500.0
			else:
				rc_fuel -= rc_thrust / 1000.0

		# finally apply forces
		set_applied_force(thrust.rotated(get_rotation()))
		set_applied_torque(_rotation_dir * rc_thrust)

func _on_MoonLander_body_entered(body):
	if self.active:
		print(str(body))
	#	print("Collision with force: " + str(get_linear_velocity()))
		# on collision damage
		if abs(get_linear_velocity().x) >= damage_treshhold or abs(get_linear_velocity().y) >= damage_treshhold:
			if self.alive == true:
				var _lander_explosion = _explosion.instance()
				for i in range(0,3):
					var _created_debris = _debris.instance()
					_created_debris.set_position(get_position())
					_game.add_child(_created_debris)
				_game.add_child(_lander_explosion)
				_lander_explosion.set_position(get_position())
				# duration, frequency, amplitude
				_camera.shake(1, 50, 10)
				self.alive = false
				self.set_visible(false)
				fuel = 0.0
				rc_fuel = 0.0
				height_over_terrain = 0.0

func _recalculate_inventory_weight():
	var item_weight = 0.0
	for item in inventory:
		item_weight += globals.get_goods_weight(item) * inventory[item]['amount']
	inventory_weight = (item_weight) * 100
#	print("Inventory weight: " + str(inventory_weight))

func add_to_inventory(item, amount):
	if item in globals.goods:
		if amount + inventory.size() <= inventory_space:
			# If same good is already in inventory just increase amount
			if item in inventory:
				inventory[item]['amount'] += amount
#				print("Increased amount of goods")
			# Else create the position
			else:
				var new_item = globals.goods[item]
				new_item['amount'] = amount
				inventory[item] = new_item
#				print("Added goods " + str(new_item) + " to inventory.")
			_recalculate_inventory_weight()
			_game.gui.add_inventory_item(item, amount)
#		else:
#			print("Not enough space in inventory! Would need " + str(amount) + " but only " + str(inventory_space - inventory.size()) + " is available.")
#	else:
#		print("Item " + str(item) + " does not exist in " + str(globals.goods) + "!")

func remove_from_inventory(item, amount):
	# Is good in inventory?
	if item in inventory:
		# Is enough of it in inventory?
#		print("Check if "+str(inventory[item]['amount'])+" is >= " + str(amount))
		if inventory[item]['amount'] >= amount:
			# Remove from GUI first, because it checks for inventory content to do its thing!
			_game.gui.remove_inventory_item(item, amount)
			# Will this set the amount of the good to zero? Then remove the item.
#			print("Check now if "+str(inventory[item]['amount']) + " - " + str(amount)+" == 0")
			if inventory[item]['amount'] - amount == 0:
				inventory.erase(item)
			# Else just decrease amount
			else:
				inventory[item]['amount'] -= amount
			_recalculate_inventory_weight()
#		else:
#			print("No " + str(amount) + " items of " + str(globals[item]['display_name']) + " found in inventory.")
#	else:
#		print("Item " + str(globals[item]['display_name']) + " not in inventory")

func has_loaded(item, amount):
	if item in inventory:
		if inventory[item]['amount'] >= amount:
			return amount
		else:
			return inventory[item]['amount']
	else:
		return false

func can_load(amount):
	return self.inventory.size() + amount <= self.inventory_space

func accept_contract(contract_id):
	var _contract = _game.get_contract(contract_id)
	self.contracts.push_back(_contract)
	_contract.accepted = true
	_game.gui.add_contract(_contract)
	_game.create_floater("Contract accepted!")

# A given amount is added to the players balance.
func add_credits(sum):
	self.credits_balance += sum
	_game.create_floater("Contract completed!\nYou earned "+str(sum)+" Cr")

# Make the player pay the given sum. If the transaction is successful,
# "true" is returned. "false" otherwise.
func pay(sum):
	if self.credits_balance - sum > 0:
		self.credits_balance -= sum
		return true
	else:
		_game.create_floater("Not enough credits!")
		return false

func refill_fuel():
	self.rc_fuel = self.rc_fuel_capacity
	self.fuel = self.fuel_capacity
