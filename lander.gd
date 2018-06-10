extends RigidBody2D

# public members
export (int) var main_engine_thrust
export (int) var rc_thrust
export (float) var fuel_capacity
export (float) var rc_fuel_capacity

# class member variables go here, for example:
var _game = null
var _engine_particles = null
var _rc_thruster_particles_right = null
var _rc_thruster_particles_left = null
var _rotation_dir = 0
var thrust = Vector2()
var fuel = 0.0
var rc_fuel = 0.0
var _rc_fuel_display = null
var _fuel_display = null
var _damage_treshhold = null
var _explosion = null
var alive = true

func _ready():
	_game = get_tree().get_current_scene()
	_engine_particles = get_node("EngineParticles")
	_rc_thruster_particles_right = get_node("RCThrusterParticles_Right")
	_rc_thruster_particles_left = get_node("RCThrusterParticles_Left")
	_rc_fuel_display = _game.get_node("CameraContainer/Camera2D/Control/rc_fuel")
	_fuel_display = _game.get_node("CameraContainer/Camera2D/Control/fuel")
	_explosion = load("res://explosion.tscn")
	_damage_treshhold = 5.0
	# sign main engine thrust negative
	main_engine_thrust = main_engine_thrust * -1
	# set initial fuel to capacity
	fuel = fuel_capacity
	rc_fuel = rc_fuel_capacity

func _process(delta):
	_fuel_display.set_region_rect(Rect2(0,0,32,(65 * fuel / fuel_capacity)))
	_rc_fuel_display.set_region_rect(Rect2(0,0,28,(54 * rc_fuel / rc_fuel_capacity)))
	if fuel <= 0:
		_engine_particles.set_emitting(false)
	if rc_fuel <= 0:
		_rc_thruster_particles_left.set_emitting(false)

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
	if abs(get_linear_velocity().x) >= _damage_treshhold and abs(get_linear_velocity().y) >= _damage_treshhold:
		var _lander_explosion = _explosion.instance()
		_game.add_child(_lander_explosion)
		_lander_explosion.set_position(get_position())
		self.alive = false
		self.set_visible(false)
		fuel = 0.0
		rc_fuel = 0.0
