extends Node2D

export (float) var main_fuel_warning_treshold = 0.2
export (float) var rc_fuel_warning_treshold = 0.15

var _lander = null
var _rc_fuel_low_warning = null
var _main_fuel_low_warning = null
var _winner_overlay = null
var _rc_fuel_display = null
var _main_fuel_display = null

func _ready():
	_rc_fuel_low_warning = get_node("Control/Fuel/RC_Fuel_Warning")
	_main_fuel_low_warning = get_node("Control/Fuel/Main_Fuel_Warning")
	_winner_overlay = get_node("Control/Winner")
	_rc_fuel_display = get_node("Control/Fuel/rc_fuel")
	_main_fuel_display = get_node("Control/Fuel/fuel")
	_lander = get_node("/root/Game/MoonLander")
	
func _process(delta):
	# Update fuel display
	_main_fuel_display.set_region_rect(Rect2(0,0,32,(65 * _lander.fuel / _lander.fuel_capacity)))
	_rc_fuel_display.set_region_rect(Rect2(0,0,28,(54 * _lander.rc_fuel / _lander.rc_fuel_capacity)))
	# Show warning if fuel is low
	if _lander.fuel / _lander.fuel_capacity < main_fuel_warning_treshold:
		if not _main_fuel_low_warning.is_blinking():
			_main_fuel_low_warning.blink()
	if _lander.rc_fuel / _lander.rc_fuel_capacity < rc_fuel_warning_treshold:
		if not _rc_fuel_low_warning.is_blinking():
			_rc_fuel_low_warning.blink()

# Show basic "You win" message on screen (for testing)
func show_winner():
	_winner_overlay.set_visible(true)
	
