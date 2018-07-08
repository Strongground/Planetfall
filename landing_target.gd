extends Node2D

# nodes
onready var _game = get_node("/root/Game")
onready var _lander = _game.get_node("MoonLander")
onready var _indicator = get_node("Indicator")
onready var _gui = get_node("/root/Game/CameraContainer/GUI")
onready var _label = get_node("Label")
onready var _pump_icon = get_node("PumpIcon")
onready var target_area = get_node("TargetArea")
# public members
export (String) var id = ""
export (String) var description = ""
export (bool) var _is_pump = false
export (float) var fuel_price_per_unit = 0.25
# internal members
var trigger_counter = 0

func _ready():
	if self.id.length() == 0:
		self.id = "generic" + str(OS.get_system_time_secs())
	self._label.set_text(self.description)
	if self._is_pump == true:
		_pump_icon.set_visible(true)
	
func is_landed():
	return self.target_area.overlaps_body(_game.lander) and _game.lander.alive and _game.lander.landed

func _process(delta):
	# If this landing target is a refueling station
	if is_landed() == true and self._is_pump and trigger_counter == 0:
		trigger_counter += 1
		var _main_fuel_price = (_lander.fuel_capacity - _lander.fuel) * fuel_price_per_unit
		var _rc_fuel_price = (_lander.rc_fuel_capacity - _lander.rc_fuel) * fuel_price_per_unit
		print("Fuel prices: Main: " + str(_main_fuel_price) + " RC: " + str(_rc_fuel_price))
		if _lander.pay(_main_fuel_price + _rc_fuel_price) == true:
			_lander.refill_fuel()
			_game.create_floater("Fuel refilled \nfor "+str(_main_fuel_price + _rc_fuel_price)+"Cr")
	if not is_landed() == true:
		trigger_counter = 0
