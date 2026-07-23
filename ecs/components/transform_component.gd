class_name TransformComponent extends RefCounted

var position: Vector2
var rotation: float

func _init(position: Vector2 = Vector2.ZERO, rotation: float = 0.0) -> void:
	self.position = position
	self.rotation = rotation
