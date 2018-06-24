extends Node

const goods = {
	'food': {
		'display_name': 'Food Supplies',
		'amount': 0,
		'weight': 1,
		'icon': preload("res://icons/goods/food_crate.png")
	},
	'spare_parts': {
		'display_name': 'Spare Parts',
		'amount': 0,
		'weight': 3,
		'icon': preload("res://icons/goods/generic_crate.png")
	}
}

func get_goods_weight(item):
	if item in goods:
		return goods[item]['weight']
	else:
		return false
		
func get_goods_name(item):
	if item in goods:
		return goods[item]['display_name']
	else:
		return false

func get_icon(item):
	if item in goods:
		return goods[item]['icon']
	else:
		return false