extends RigidBody2D

# public members
export (int) var main_engine_thrust = 80
export (int) var rc_thrust = 100
export (float) var fuel_capacity = 200
export (float) var rc_fuel_capacity = 50
export (float) var damage_treshhold = 10
export (int) var inventory_space = 5

# class members
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
var thrust = Vector2()
var fuel = 0.0
var rc_fuel = 0.0
var alive = true
var landed = false
var height_over_terrain = 0.0
var inventory = {}
var inventory_weight = 0.0
var craft_weight = 0.0

func _ready():
	# sign main engine thrust negative
	main_engine_thrust = main_engine_thrust * -1
	# set initial fuel to capacity
	fuel = fuel_capacity
	rc_fuel = rc_fuel_capacity
	craft_weight = get_weight() * 100

func _process(delta):
	set_weight(craft_weight + inventory_weight)
	
	if fuel <= 0:
		_engine_particles.set_emitting(false)
		thrust = Vector2(0,0)
	if rc_fuel <= 0:
		_rc_thruster_particles_left.set_emitting(false)
		_rc_thruster_particles_right.set_emitting(false)
		_rotation_dir = 0
	# Calculate height over terrain
	# _ray.set_global_rotation_degrees(90)
	_raycast.set_cast_to(Vector2(1000, 0))
	_raycast.set_global_rotation_degrees(90)
	_terrain_collision = _raycast.get_collision_point()
	# _marker1.set_position(_terrain_collision)
	# _label1.set_text("Ray global rotation: " + str(_ray.get_global_rotation()))
	# _label2.set_text("Lander rotation: " + str(self.get_rotation()))
	height_over_terrain = _terrain_collision.distance_to(self.get_global_transform().get_origin()) - 10
	if height_over_terrain < 0:
		height_over_terrain = 0

func _integrate_forces(state):
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
		rc_fuel -= rc_thrust / 1000.0

	# finally apply forces
	set_applied_force(thrust.rotated(get_rotation()))
	set_applied_torque(_rotation_dir * rc_thrust)

# On collision
func _on_MoonLander_body_entered(body):
	print("Collision with force: " + str(get_linear_velocity()))
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
		item_weight += globals.get_weight(item) * inventory[item]['amount']
	inventory_weight = (item_weight) * 100
	print("Inventory weight: " + str(inventory_weight))
		
func add_to_inventory(item, amount):
	if item in globals.goods:
		if amount + inventory.size() <= inventory_space:
			# If same good is already in inventory just increase amount 
			if item in inventory:
				inventory[item]['amount'] += amount
				print("Increased amount of goods")
			# Else create the position
			else:
				var new_item = globals.goods[item]
				new_item['amount'] = amount
				inventory[item] = new_item
				print("Added goods " + str(new_item) + " to inventory.")
			_recalculate_inventory_weight()
		else:
			print("Not enough space in inventory! Would need " + str(amount) + " but only " + str(inventory_space - inventory.size()) + " is available.")
	else:
		print("Item " + str(item) + " does not exist in " + str(globals.goods) + "!")

func remove_from_inventory(item, amount):
	# Is good in inventory?
	if item in inventory:
		# Is enough of it in inventory?
		if inventory[item]['amount'] >= amount:
			# Will this set the amount of the good to zero? Then remove the item.
			if inventory[item]['amount'] - amount == 0:
				inventory.erase(item)
			# Else just decrease amount
			else:
				inventory[item]['amount'] -= amount
			_recalculate_inventory_weight()
		else:
			print("No " + str(amount) + " items of " + str(globals[item]['display_name']) + " found in inventory.")
	else:
		print("Item " + str(globals[item]['display_name']) + " not in inventory")

func has_loaded(item, amount):
	if item in inventory and inventory[item]['amount'] >= amount:
		return true
	else:
		return false