extends RigidBody2D

# public members
export (int) var main_engine_thrust = 80
export (int) var rc_thrust = 100
export (float) var fuel_capacity = 200
export (float) var rc_fuel_capacity = 50
export (float) var damage_treshhold = 10

# class members
onready var _game = get_tree().get_current_scene()
onready var _camera = _game.find_node("Camera2D")
onready var _engine_particles = get_node("EngineParticles")
onready var _rc_thruster_particles_right = get_node("RCThrusterParticles_Right")
onready var _rc_thruster_particles_left = get_node("RCThrusterParticles_Left")
onready var _explosion = load("res://explosion.tscn")
onready var _debris = load("res://lander_debris.tscn")
var _rotation_dir = 0
var _has_landed_for = 0
var thrust = Vector2()
var fuel = 0.0
var rc_fuel = 0.0
var alive = true
var landed = false

func _ready():
	# sign main engine thrust negative
	main_engine_thrust = main_engine_thrust * -1
	# set initial fuel to capacity
	fuel = fuel_capacity
	rc_fuel = rc_fuel_capacity

func _process(delta):
	if fuel <= 0:
		_engine_particles.set_emitting(false)
		thrust = Vector2(0,0)
	if rc_fuel <= 0:
		_rc_thruster_particles_left.set_emitting(false)
		_rc_thruster_particles_right.set_emitting(false)
		_rotation_dir = 0

func _integrate_forces(state):
	if fuel <= 0:
		fuel = 0

	# Input for vehicle controls
	if Input.is_action_just_pressed("ui_up"):
		if fuel <= 0:
			pass
		else:
			thrust = Vector2(main_engine_thrust,0)
			_engine_particles.set_emitting(true)
	if Input.is_action_just_released("ui_up"):
		thrust = Vector2(0,0)
		_engine_particles.set_emitting(false)

	if Input.is_action_just_pressed("ui_right"):
		if rc_fuel <= 0:
			pass
		else:
			_rotation_dir += 1
			_rc_thruster_particles_right.set_emitting(true)
	if Input.is_action_just_released("ui_right"):
		_rotation_dir = 0
		_rc_thruster_particles_right.set_emitting(false)

	if Input.is_action_just_pressed("ui_left"):
		if rc_fuel <= 0:
			pass
		else:
			_rotation_dir -= 1
			_rc_thruster_particles_left.set_emitting(true)
	if Input.is_action_just_released("ui_left"):
		_rotation_dir = 0
		_rc_thruster_particles_left.set_emitting(false)
	
	# print(str(abs(get_linear_velocity().x)) + ", " + str(abs(get_linear_velocity().y)))
	print("Has landed: " + str(landed) + ", has landed for: " + str(_has_landed_for))
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
