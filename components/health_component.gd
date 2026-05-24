class_name HealthComponent extends RefCounted

var current: int
var max: int

func _init(current: int = -1, max: int = 0) -> void:
	self.current = current if current != -1 else max
	self.max = max
