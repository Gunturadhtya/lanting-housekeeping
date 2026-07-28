class_name MapView
extends Control

signal node_activated(node_id : String, node_type : int)

@export var node_button_scene : PackedScene
@export var floor_spacing : float = 220.0
@export var top_margin : float = 110.0
@export var side_margin : float = 70.0
@export var default_node_size : Vector2 = Vector2(64, 64)
@export var line_color : Color = Color(0.8, 0.78, 0.65, 0.5)
@export var available_line_color : Color = Color(0.95, 0.8, 0.3, 0.95)
@export var line_width : float = 5.0

@onready var scroll : ScrollContainer = %Scroll
@onready var content : MapCanvas = %Content

var _map_data : Dictionary = {}
var _positions : Dictionary = {}
var _buttons : Dictionary = {}

func _ready() -> void:
	var data := RunManager.get_map_data()
	node_activated.connect(_on_map_view_node_activated)
	if not data.is_empty():
		display_map(data)

func display_map(map_data : Dictionary) -> void:
	_map_data = map_data
	for child in content.get_children():
		child.queue_free()
	_positions.clear()
	_buttons.clear()

	var floor_node_ids : Array = map_data.get("floor_node_ids", [])
	var floor_count : int = floor_node_ids.size()
	if floor_count == 0:
		return

	var content_width : float = maxf(scroll.size.x - side_margin * 2.0, 500.0)
	var content_height : float = top_margin * 2.0 + floor_spacing * maxi(floor_count - 1, 0)
	content.custom_minimum_size = Vector2(content_width + side_margin * 2.0, content_height)
	content.size = content.custom_minimum_size

	for floor_idx in range(floor_count):
		var ids : Array = floor_node_ids[floor_idx]
		var count : int = ids.size()
		for col in range(count):
			var node_id : String = ids[col]
			var t : float = (float(col) + 0.5) / float(count)
			var x : float = side_margin + t * content_width
			var y : float = content_height - top_margin - float(floor_idx) * floor_spacing
			_positions[node_id] = Vector2(x, y)

	for node_id in _positions.keys():
		_spawn_button(node_id)

	_refresh()
	call_deferred("_scroll_to_current")

func _spawn_button(node_id : String) -> void:
	var info : Dictionary = _map_data["nodes"][node_id]
	var btn : Button
	if node_button_scene:
		btn = node_button_scene.instantiate()
	else:
		btn = Button.new()
		btn.custom_minimum_size = default_node_size
	content.add_child(btn)

	var size : Vector2 = btn.custom_minimum_size if btn.custom_minimum_size != Vector2.ZERO else default_node_size
	btn.position = _positions[node_id] - size * 0.5

	if btn.has_method("setup"):
		btn.setup(info.get("type", MapGenerator.NodeType.COMBAT))
	else:
		btn.text = MapGenerator.node_type_label(info.get("type", 0)).left(1)

	btn.pressed.connect(_on_node_pressed.bind(node_id))
	_buttons[node_id] = btn

func _reachable_ids() -> Array:
	var current_id : String = RunManager.get_current_node_id()
	if current_id.is_empty():
		return _map_data.get("start_ids", [])
	return _map_data.get("nodes", {}).get(current_id, {}).get("connections", [])

func _refresh() -> void:
	var visited : Array = RunManager.get_visited_node_ids()
	var reachable := _reachable_ids()
	var current_id : String = RunManager.get_current_node_id()

	for node_id in _buttons.keys():
		var btn : Button = _buttons[node_id]
		var is_available : bool = node_id in reachable
		var is_visited : bool = node_id in visited
		if btn.has_method("set_state"):
			btn.set_state(is_available, is_visited, node_id == current_id)
		else:
			btn.disabled = not is_available
			btn.modulate = Color(1, 1, 1, 1) if (is_available or is_visited or node_id == current_id) else Color(1, 1, 1, 0.35)

	_redraw_lines(reachable, visited)

func _redraw_lines(reachable : Array, visited : Array) -> void:
	var lines : Array[Dictionary] = []
	var nodes : Dictionary = _map_data.get("nodes", {})
	for node_id in nodes.keys():
		if not _positions.has(node_id):
			continue
		var info : Dictionary = nodes[node_id]
		var from_pos : Vector2 = _positions[node_id]
		for next_id in info.get("connections", []):
			if not _positions.has(next_id):
				continue
			var to_pos : Vector2 = _positions[next_id]
			var is_hot : bool = (node_id in visited) and (next_id in reachable)
			lines.append({
				"from": from_pos,
				"to": to_pos,
				"color": available_line_color if is_hot else line_color,
				"width": line_width,
			})
	content.set_lines(lines)

func _on_node_pressed(node_id : String) -> void:
	if node_id not in _reachable_ids():
		return
	var info : Dictionary = _map_data["nodes"][node_id]
	RunManager.set_current_node_id(node_id)
	_refresh()
	node_activated.emit(node_id, info.get("type", MapGenerator.NodeType.COMBAT))

func _scroll_to_current() -> void:
	var target_id : String = RunManager.get_current_node_id()
	if target_id.is_empty():
		var starts : Array = _map_data.get("start_ids", [])
		if not starts.is_empty():
			target_id = starts[0]
	if target_id.is_empty() or not _positions.has(target_id):
		return
	var target_y : float = _positions[target_id].y
	scroll.scroll_vertical = int(clampf(target_y - scroll.size.y * 0.5, 0.0, content.size.y))
	
func _on_map_view_node_activated(node_id, node_type) -> void:
	match node_type:
		MapGenerator.NodeType.COMBAT, MapGenerator.NodeType.ELITE, MapGenerator.NodeType.BOSS:
			SceneLoader.load_scene("res://scenes/game_scene/stage/combat_stage.tscn")
		MapGenerator.NodeType.MARKET:
			SceneLoader.load_scene("res://scenes/shop/shop_stage.tscn")
		MapGenerator.NodeType.WORKSHOP:
			pass # TODO
		MapGenerator.NodeType.EVENT, MapGenerator.NodeType.TREASURE:
			pass # TODO
