class_name MapGenerator
extends RefCounted

enum NodeType { COMBAT, ELITE, MARKET, WORKSHOP, EVENT, TREASURE, BOSS }

const NODE_TYPE_LABELS := {
	NodeType.COMBAT: "Pertarungan",
	NodeType.ELITE: "Elite",
	NodeType.MARKET: "Market",
	NodeType.WORKSHOP: "Bengkel",
	NodeType.EVENT: "Skenario",
	NodeType.TREASURE: "Harta Karun",
	NodeType.BOSS: "Boss",
}

static func node_type_label(type : int) -> String:
	return NODE_TYPE_LABELS.get(type, "?")

static func generate(
	run_seed : int = -1,
	floor_count : int = 4,
	min_nodes_per_floor : int = 2,
	max_nodes_per_floor : int = 4,
	max_connections_per_node : int = 2
) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	rng.seed = run_seed if run_seed != -1 else randi()

	var floor_node_ids : Array = []
	var nodes : Dictionary = {}

	for floor_idx in range(floor_count):
		var count : int = 1
		if floor_idx == floor_count - 1:
			count = 1
		else:
			count = rng.randi_range(min_nodes_per_floor, max_nodes_per_floor)

		var ids : Array = []
		for col in range(count):
			var node_id : String = "f%d_n%d" % [floor_idx, col]
			var type : int = _pick_node_type(floor_idx, floor_count, rng)
			nodes[node_id] = {
				"id": node_id,
				"type": type,
				"floor": floor_idx,
				"column": col,
				"connections": [],
			}
			ids.append(node_id)
		floor_node_ids.append(ids)

	for floor_idx in range(floor_count - 1):
		var current_ids : Array = floor_node_ids[floor_idx]
		var next_ids : Array = floor_node_ids[floor_idx + 1]
		for node_id in current_ids:
			var connection_count : int = 1
			if next_ids.size() > 1 and rng.randf() < 0.45:
				connection_count = mini(max_connections_per_node, next_ids.size())
			var targets := _pick_nearby_targets(node_id, current_ids, next_ids, connection_count, rng)
			nodes[node_id]["connections"] = targets

		var reached : Dictionary = {}
		for node_id in current_ids:
			for target_id in nodes[node_id]["connections"]:
				reached[target_id] = true
		for target_id in next_ids:
			if not reached.has(target_id):
				var source_id : String = current_ids[rng.randi_range(0, current_ids.size() - 1)]
				nodes[source_id]["connections"].append(target_id)

	var start_ids : Array = floor_node_ids[0].duplicate()
	var boss_id : String = floor_node_ids[floor_count - 1][0]
	nodes[boss_id]["type"] = NodeType.BOSS
	for node_id in start_ids:
		nodes[node_id]["type"] = NodeType.COMBAT

	return {
		"seed": rng.seed,
		"floor_node_ids": floor_node_ids,
		"start_ids": start_ids,
		"boss_id": boss_id,
		"nodes": nodes,
	}

static func _pick_nearby_targets(node_id : String, current_ids : Array, next_ids : Array, count : int, rng : RandomNumberGenerator) -> Array:
	var col : int = current_ids.find(node_id)
	var ratio : float = float(col) / float(maxi(current_ids.size() - 1, 1))
	var center_col : int = int(round(ratio * float(next_ids.size() - 1)))

	var candidates : Array = next_ids.duplicate()
	candidates.sort_custom(func(a, b):
		var a_col : int = next_ids.find(a)
		var b_col : int = next_ids.find(b)
		return absi(a_col - center_col) < absi(b_col - center_col)
	)

	var jitter_pool : Array = candidates.slice(0, mini(candidates.size(), maxi(count + 1, 2)))
	_shuffle_with_rng(jitter_pool, rng)
	var result : Array = []
	for i in range(mini(count, jitter_pool.size())):
		if not result.has(jitter_pool[i]):
			result.append(jitter_pool[i])
	if result.is_empty() and not candidates.is_empty():
		result.append(candidates[0])
	return result

static func _shuffle_with_rng(array : Array, rng : RandomNumberGenerator) -> void:
	for i in range(array.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = array[i]
		array[i] = array[j]
		array[j] = tmp

static func _pick_node_type(floor_idx : int, floor_count : int, rng : RandomNumberGenerator) -> int:
	if floor_idx == 0:
		return NodeType.COMBAT
	if floor_idx == floor_count - 1:
		return NodeType.BOSS

	var weights : Dictionary = {
		NodeType.COMBAT: 45.0,
		NodeType.ELITE: 0.0,
		NodeType.MARKET: 10.0,
		NodeType.WORKSHOP: 15.0,
		NodeType.EVENT: 20.0,
		NodeType.TREASURE: 10.0,
	}
	if floor_idx >= 3:
		weights[NodeType.ELITE] = 15.0 + float(floor_idx) * 1.5
		weights[NodeType.COMBAT] = 40.0

	var total : float = 0.0
	for w in weights.values():
		total += w
	var roll : float = rng.randf() * total
	var accum : float = 0.0
	for type in weights.keys():
		accum += weights[type]
		if roll <= accum:
			return type
	return NodeType.COMBAT
