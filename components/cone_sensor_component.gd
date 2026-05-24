class_name ConeSensorComponent extends RefCounted

var radius: float
var fov_degrees: float

func _init(radius: float = 1.0, fov_degrees = 1.0):
	self.radius = radius
	self.fov_degrees = fov_degrees
