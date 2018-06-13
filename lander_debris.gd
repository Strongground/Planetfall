extends RigidBody2D

# class member variables go here, for example:
var _debris = null
var _smoke_trail = null
var _once = false
var _speed = 300
var _i = 0
var _colliders = null

func _ready():
	_debris = get_node("Debris")
	_smoke_trail = get_node("SmokeTrail")
	var _random_sprite_positions = [0,18,36,54,72]
	var _random_debris = _random_sprite_positions[randi() % 5]
	_debris.set_region_rect(Rect2(_random_debris,0,18,18))

func _integrate_forces(state):
	_i = _speed * 10 / 300
	if _once == false:
		randomize()
		add_force(Vector2(0,0), Vector2(randi() % _speed * 3 - _speed * 3 / 2,_speed*-1))
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
	
	_colliders = get_colliding_bodies()
	if not _colliders.empty():
		var _collider = null
		for _collider in _colliders:
			if _collider.get_name() == "Level":
				_smoke_trail.set_emitting(false)
				set_contact_monitor(false)
				set_max_contacts_reported(0)
