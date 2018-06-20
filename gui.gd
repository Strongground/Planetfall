extends Node2D

export (float) var main_fuel_warning_treshold = 0.2
export (float) var rc_fuel_warning_treshold = 0.15

onready var _lander = get_node("/root/Game/MoonLander")
onready var _main_fuel_low_warning = get_node("Control/Fuel Panel/MarginContainer/VBoxContainer/MainFuelDisplay/Main_Fuel_Warning")
onready var _rc_fuel_low_warning = get_node("Control/Fuel Panel/MarginContainer/VBoxContainer/RCFuelDisplay/RC_Fuel_Warning")
onready var _winner_overlay = get_node("Control/Winner")
onready var _main_fuel_display = get_node("Control/Fuel Panel/MarginContainer/VBoxContainer/RCFuelDisplay/RCFuel_Bar")
onready var _rc_fuel_display = get_node("Control/Fuel Panel/MarginContainer/VBoxContainer/MainFuelDisplay/MainFuel_Bar")
onready var _hot_display = get_node("Control/Navigation Panel/MarginContainer/VBoxContainer/NinePatchRect/HOT_Display")

func _process(delta):
	# Update fuel display
	_main_fuel_display.set_value((_lander.fuel / _lander.fuel_capacity)*100)
	_rc_fuel_display.set_value((_lander.rc_fuel / _lander.rc_fuel_capacity)*100)
	# Update height over terrain
	_hot_display.set_text(str(floor(_lander.height_over_terrain)))
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
	
