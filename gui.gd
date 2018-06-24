extends Node2D

export (float) var main_fuel_warning_treshold = 0.2
export (float) var rc_fuel_warning_treshold = 0.15

onready var _lander = get_node("/root/Game/MoonLander")
onready var _main_fuel_low_warning = get_node("Control/Fuel Panel/MarginContainer/VBoxContainer/MainFuelDisplay/Main_Fuel_Warning")
onready var _rc_fuel_low_warning = get_node("Control/Fuel Panel/MarginContainer/VBoxContainer/RCFuelDisplay/RC_Fuel_Warning")
onready var _winner_overlay = get_node("Control/Winner")
onready var _main_fuel_display = get_node("Control/Fuel Panel/MarginContainer/VBoxContainer/MainFuelDisplay/MainFuel_Bar")
onready var _rc_fuel_display = get_node("Control/Fuel Panel/MarginContainer/VBoxContainer/RCFuelDisplay/RCFuel_Bar")
onready var _hot_display = get_node("Control/Navigation Panel/MarginContainer/VBoxContainer/NinePatchRect/HOT_Display")
onready var _inventory_container = get_node("Control/Inventory Panel/MarginContainer/VBoxContainer/Inventory")
onready var _inventory_slot = preload("res://inventory_slot.tscn")
onready var _credits_display = get_node("Control/Credits Panel/MarginContainer/VBoxContainer/NinePatchRect/Credits_Display")

var _inventory_slots = []

func _ready():
	enumerate_inventory_slots()

func _process(delta):
	# Update height over terrain
	_hot_display.set_text(str(floor(_lander.height_over_terrain)))
	# Update fuel display
	_main_fuel_display.set_value((_lander.fuel / _lander.fuel_capacity)*100)
	_rc_fuel_display.set_value((_lander.rc_fuel / _lander.rc_fuel_capacity)*100)
	# Show warning if fuel is low
	if _lander.fuel / _lander.fuel_capacity < main_fuel_warning_treshold:
		if not _main_fuel_low_warning.is_blinking():
			_main_fuel_low_warning.blink()
	if _lander.rc_fuel / _lander.rc_fuel_capacity < rc_fuel_warning_treshold:
		if not _rc_fuel_low_warning.is_blinking():
			_rc_fuel_low_warning.blink()
	_credits_display.set_text(str(_lander.credits_balance))
			
# Create inventory slots according to craft capacity
# @TODO Make panel change width dynamically based on number of slots
func enumerate_inventory_slots():
	for i in range(0, _lander.inventory_space):
		var _created_slot = _inventory_slot.instance()
		_created_slot.set_name("InventorySlot" + str(i))
		_inventory_container.add_child(_created_slot)
		_inventory_slots.push_back(_created_slot)

# Show basic "You win" message on screen (for testing)
func show_winner():
	_winner_overlay.set_visible(true)
	
# Return the index of the slot where the given item fits
# This means either a slot where a similar item already exists or
# the next free slot.
func _get_inventory_slot(item):
	# Check if item is already loaded in inventory
	var _inventory_as_array = _lander.inventory.keys()
	var _existing_good_at_index = _inventory_as_array.find(item)
	if _existing_good_at_index >= 0:
		return _existing_good_at_index
	# Else create it new
	else:
		# Check if space is available
		if _inventory_as_array.size() < _lander.inventory_space:
			return _inventory_as_array.size()
		else:
			return -1
	
# Add inventory item
func add_inventory_item(item, amount):
	if item in globals.goods:
		var _index = _get_inventory_slot(item)
		var _goods_icon = _inventory_slots[_index].get_node("GoodsIcon")
		var _goods_counter = _inventory_slots[_index].get_node("Amount")
		_goods_icon.set_visible(true)
		_goods_icon.set_texture(globals.goods[item]['icon'])
		_goods_counter.set_visible(true)
		_goods_counter.set_text(str(amount))

# Remove inventory item
func remove_inventory_item(item, amount):
	if item in globals.goods:
		var _inventory_as_array = _lander.inventory.keys()
		var _existing_good_at_index = _inventory_as_array.find(item)
		print("Goods index in inventory array: " + str(_existing_good_at_index))
		# Check if item exists in inventory
		if _existing_good_at_index >= 0:
			print("Item found in inventory")
			var _goods_icon = _inventory_slots[_existing_good_at_index].get_node("GoodsIcon")
			var _goods_counter = _inventory_slots[_existing_good_at_index].get_node("Amount")
			# Remove item completely
			if _lander.inventory[item]['amount'] - amount <= 0:
				print("Decided to remove completely")
				_goods_icon.set_visible(false)
				_goods_counter.set_visible(false)
			# Just decrease item amount
			else:
				print("Decided to just decrease amount")
				_goods_counter.set_text(_lander.inventory[item]['amount'] - amount)
		
# 
