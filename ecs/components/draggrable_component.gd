class_name DraggableComponent extends RefCounted

var is_being_dragged: bool
var drag_start: Vector2

func _init(is_being_dragged: bool = false, drag_start: Vector2 = Vector2.ZERO) -> void:
	self.is_being_dragged = is_being_dragged
	self.drag_start = drag_start
