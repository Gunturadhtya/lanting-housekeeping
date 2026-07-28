class_name RunMapProgressOps
extends RefCounted

static func set_current_node_id(state : RunManager, node_id : String) -> void:
	state.current_node_id = node_id
	if not node_id.is_empty() and node_id not in state.visited_node_ids:
		state.visited_node_ids.append(node_id)
