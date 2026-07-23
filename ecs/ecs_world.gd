class_name ECSWorld
extends RefCounted

signal entity_died(entity_id : int)
signal entity_damaged(entity_id : int, amount : int)

var _next_id : int = 0
var _components : Dictionary = {} # Script -> Dictionary[int, RefCounted]
var _entity_types : Dictionary = {} # int -> Array[Script]
var _entity_nodes : Dictionary = {} # int -> Node2D

func create_entity(node : Node2D = null) -> int:
	var id := _next_id
	_next_id += 1
	_entity_types[id] = []
	if node:
		_entity_nodes[id] = node
	return id

func add_component(entity_id : int, component : RefCounted) -> void:
	assert(_entity_types.has(entity_id), "add_component called on an unknown entity id")
	var type : Script = component.get_script()
	if not _components.has(type):
		_components[type] = {}
	_components[type][entity_id] = component
	if type not in _entity_types[entity_id]:
		_entity_types[entity_id].append(type)

func get_component(entity_id : int, type : Script) -> RefCounted:
	if _components.has(type):
		return _components[type].get(entity_id)
	return null

func has_component(entity_id : int, type : Script) -> bool:
	return _components.has(type) and _components[type].has(entity_id)

func get_node(entity_id : int) -> Node2D:
	return _entity_nodes.get(entity_id)

func query(types : Array) -> Array:
	if types.is_empty():
		return []
	var smallest : Array = []
	var smallest_size := -1
	for type in types:
		if not _components.has(type):
			return []
		var size : int = _components[type].size()
		if smallest_size == -1 or size < smallest_size:
			smallest_size = size
			smallest = _components[type].keys()
	var result := []
	for id in smallest:
		var owns_all := true
		for type in types:
			if not _components[type].has(id):
				owns_all = false
				break
		if owns_all:
			result.append(id)
	return result

func destroy_entity(entity_id : int) -> void:
	if not _entity_types.has(entity_id):
		return
	for type in _entity_types[entity_id]:
		_components[type].erase(entity_id)
	_entity_types.erase(entity_id)
	_entity_nodes.erase(entity_id)

func get_all_entities() -> Array:
	return _entity_types.keys()
