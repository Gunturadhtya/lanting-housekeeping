class_name DropZoneValidator
extends RefCounted

var _viewport_provider : Node
var _hand_area_height : float

func _init(viewport_provider : Node, hand_area_height : float) -> void:
	_viewport_provider = viewport_provider
	_hand_area_height = hand_area_height

func is_within_battlefield(world_position : Vector2) -> bool:
	var viewport_size := _viewport_provider.get_viewport().get_visible_rect().size
	if world_position.y < 0.0 or world_position.y > viewport_size.y - _hand_area_height:
		return false
	if world_position.x < 0.0 or world_position.x > viewport_size.x:
		return false
	return true
