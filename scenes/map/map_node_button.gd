class_name MapNodeButton
extends Button

const AVAILABLE_COLOR := Color(1, 1, 1, 1)
const CURRENT_COLOR := Color(1.0, 0.95, 0.55, 1.0)
const VISITED_COLOR := Color(0.6, 0.6, 0.6, 1.0)
const LOCKED_COLOR := Color(1, 1, 1, 0.35)

const ICON_TEXTURES := {
	MapGenerator.NodeType.COMBAT: preload("res://assets/sprites/ui/map_icon_battle.png"),
	MapGenerator.NodeType.ELITE: preload("res://assets/sprites/ui/map_icon_battle.png"),
	MapGenerator.NodeType.MARKET: preload("res://assets/sprites/ui/map_icon_shop.png"),
	MapGenerator.NodeType.WORKSHOP: preload("res://assets/sprites/ui/map_icon_port.png"),
	MapGenerator.NodeType.EVENT: preload("res://assets/sprites/ui/map_icon_event.png"),
	MapGenerator.NodeType.TREASURE: preload("res://assets/sprites/ui/map_icon_treasure.png"),
	MapGenerator.NodeType.BOSS: preload("res://assets/sprites/ui/map_icon_boss_battle.png"),
}

@onready var icon_label : Label = %IconLabel
@onready var icon_rect : TextureRect = %IconRect

var node_type : int = 0

func setup(type : int) -> void:
	node_type = type
	if icon_label:
		icon_label.text = ""
		tooltip_text = MapGenerator.node_type_label(type)
	if icon_rect:
		icon_rect.texture = ICON_TEXTURES.get(type)

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
