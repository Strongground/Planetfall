extends Node2D

# Public members
export (String) var title = ""
export (String) var description = ""
export (bool) var timed = false
export (int) var pay = 0
export (String) var goods = "none"
export (int) var goods_amount = 0
export (String) var origin_id = ""
export (String) var target_id = ""
export (String) var id = ""
# Simple members
var fulfilled = false
var accepted = false
var goods_origin_loaded = false
# Members that are declared on ready
onready var _game = get_tree().get_current_scene()

func _ready():
	# generate title if empty
	if self.title == null or self.title == "" or self.title == "Null":
		self.title = self._generate_title()
	# if id is given, set it as name of the node. otherwise generate id and use that.
	if self.id == "":
		self.id = self._generate_id()
	self.set_name(self.id)
	# auto generate description of contract
	if typeof(_game.get_landing_target(origin_id)) != TYPE_NIL && \
		typeof(_game.get_landing_target(target_id)) != TYPE_NIL:
		if description.length() == 0:
			description = "Deliver "+str(goods_amount)+" units of "+str(goods['display_name'])+" from "+str(_game.get_landing_target(origin_id).get("description"))+" to "+str(_game.get_landing_target(target_id).get("description"))+". Payout is "+str(pay)+"‡"	
	else:
		print("ERROR: One or both of the landing targets for contract "+ self.id +" are not existing!")

func _generate_title():
	return "Delivery: " + str(goods_amount)+" "+str(goods['display_name'])

func _generate_id():
	return str(self.title) + str(OS.get_system_time_secs())
	
func _process(delta):
	if self.accepted and not self.fulfilled:
		if _game.get_landing_target(origin_id).is_landed():
#		if _landed_at_landing_target(origin_id):
#			print("Landed at origin")
#			print("Conditions: ")
#			print("Lander has not already loaded goods from here: " + str(not self.goods_origin_loaded))
#			print("Lander can load goods: " + str(_game.lander.can_load(goods_amount)))
			if not self.goods_origin_loaded and _game.lander.can_load(goods_amount):
				_game.lander.add_to_inventory(goods, goods_amount)
				self.goods_origin_loaded = true
#		if _landed_at_landing_target(target_id):
		if _game.get_landing_target(target_id).is_landed():
#			print("Landed at target")
#			print("Conditions:")
#			print("Lander has needed goods: "+str(_game.lander.has_loaded(goods, goods_amount)))
			if _game.lander.has_loaded(goods, goods_amount):
				_game.lander.remove_from_inventory(goods, goods_amount)
				_game.lander.add_credits(pay)
				self.fulfilled = true