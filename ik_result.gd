class_name IkResult
extends RefCounted

var reachable: bool
var angle_root: float
var angle_middle: float

func _init(
	a_reachable: bool,
	a_angle_root: float,
	a_angle_middle: float,
):
	self.reachable = a_reachable
	self.angle_root = a_angle_root
	self.angle_middle = a_angle_middle
		
