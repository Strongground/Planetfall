extends RigidBody2D

# class member variables go here, for example:
var _debris = null
var _smoke_trail = null
var _once = false
var _speed = 300
var _i = 0
var _j = 0

func _ready():
	randomize()
	_debris = get_node("Debris")
	_smoke_trail = get_node("SmokeTrail")
	var _random_sprite_positions = [0,18,36,54,72]
	var _random_debris = _random_sprite_positions[randi() % 5]
	_debris.set_region_rect(Rect2(_random_debris,0,18,18))

func _integrate_forces(state):
	_i = _speed * 10 / 300
	_j = 10
	if _once == false:
		add_force(Vector2(0,0), Vector2(randi() % _speed - (_speed/2),_speed*-1))
		_once = true
	# Gradually cancel out y-axis forces
	if get_applied_force().y < 0:
		add_force(Vector2(0,0), Vector2(0,_i))
	# Gradually cancel out x-axis forces
	if get_applied_force().x > 0:
		add_force(Vector2(0,0), Vector2(_i*-1,0))
	if get_applied_force().x < 0:
		add_force(Vector2(0,0), Vector2(_i,0))
	_i += _i
	print(get_colliding_bodies())
	
#	if not get_colliding_bodies().empty():
#		_smoke_trail.set_emitting(false)
#		set_sleeping(true)
