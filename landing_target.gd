extends Node2D

# nodes
onready var _game = get_node("/root/Game")
onready var _lander = _game.get_node("MoonLander")
onready var _indicator = get_node("Indicator")
onready var _gui = get_node("/root/Game/CameraContainer/GUI")
onready var _label = get_node("Label")
onready var target_area = get_node("TargetArea")
# members
export (String) var id = ""
export (String) var description = ""

func _ready():
	if self.id.length() == 0:
		self.id = "generic" + str(OS.get_system_time_secs())
	self._label.set_text(self.description)