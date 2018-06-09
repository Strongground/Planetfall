extends RigidBody2D

# public members
export (int) var main_engine_thrust
export (int) var rc_thrust

# class member variables go here, for example:
var game = null
var engine_particles = null
var rc_thruster_particles_right = null
var rc_thruster_particles_left = null
var thrust = Vector2()

func _ready():
	game = get_tree().get_current_scene()
	engine_particles = get_node("EngineParticles")
	rc_thruster_particles_right = get_node("RCThrusterParticles_Right")
	rc_thruster_particles_left = get_node("RCThrusterParticles_Left")
	main_engine_thrust = main_engine_thrust * -1

#func _process(delta):
#	pass

func _integrate_forces(state):

	if Input.is_action_just_pressed("ui_up"):
		thrust = Vector2(main_engine_thrust,0)
		engine_particles.set_emitting(true)

	if Input.is_action_just_released("ui_up"):
		thrust = Vector2(0,0)
		engine_particles.set_emitting(false)

	# print(thrust.rotated(get_rotation()))
	print(self.get_applied_force())
	set_applied_force(thrust.rotated(get_rotation()))