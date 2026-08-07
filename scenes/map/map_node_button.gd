class_name MapNodeButton
extends Button

const AVAILABLE_COLOR := Color(1, 1, 1, 1)
const CURRENT_COLOR := Color(1.0, 0.95, 0.55, 1.0)
const VISITED_COLOR := Color(0.6, 0.6, 0.6, 1.0)
const LOCKED_COLOR := Color(1, 1, 1, 0.35)

@onready var icon_label : Label = %IconLabel

var node_type : int = 0

func setup(type : int) -> void:
	node_type = type
	if icon_label:
		icon_label.text = MapGenerator.node_type_label(type)
		tooltip_text = MapGenerator.node_type_label(type)

func set_state(is_available : bool, is_visited : bool, is_current : bool) -> void:
	disabled = not is_available
	if is_current:
		modulate = CURRENT_COLOR
	elif is_visited:
		modulate = VISITED_COLOR
	elif is_available:
		modulate = AVAILABLE_COLOR
	else:
		modulate = LOCKED_COLOR
