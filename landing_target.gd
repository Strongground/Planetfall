extends Node2D

var indicator = null
var target_area = null

func _ready():
	indicator = get_node("Indicator")
	target_area = get_node("TargetArea")

func _on_TargetArea_area_entered(area):
	print("Something entered the area: " + str(area))
