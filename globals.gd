extends Node

const goods = {
	'food': {
		'display_name': 'Food Supplies',
		'amount': 0,
		'weight': 1,
		'icon': ''
	},
	'spare_parts': {
		'display_name': 'Spare Parts',
		'amount': 0,
		'weight': 3,
		'icon': ''
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