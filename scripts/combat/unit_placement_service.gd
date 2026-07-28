class_name UnitPlacementService
extends RefCounted

var placed_unit_ids : Array[int] = []
var placed_unit_cards : Dictionary = {} # entity_id -> CardResource

var _world : ECSWorld
var _parent : Node

func _init(world : ECSWorld, parent : Node) -> void:
	_world = world
	_parent = parent

func place_unit(card : CardResource, drop_position : Vector2) -> int:
	if card.unit_scene == null:
		return -1
	var unit : PlayerUnitEntity = card.unit_scene.instantiate()
	unit.max_health = card.unit_max_health
	unit.move_speed = card.unit_move_speed
	unit.sensor_radius = card.unit_sensor_radius
	unit.sensor_fov_degrees = card.unit_sensor_fov_degrees
	unit.attack_damage = card.unit_attack_damage
	unit.attack_range = card.unit_attack_range
	unit.attack_cooldown = card.unit_attack_cooldown
	_parent.add_child(unit)
	unit.position = drop_position
	unit.setup(_world)
	placed_unit_ids.append(unit.entity_id)
	placed_unit_cards[unit.entity_id] = card
	return unit.entity_id

func find_unit_at(position : Vector2, max_distance : float = 48.0) -> int:
	var closest_id := -1
	var closest_distance := max_distance
	for id in placed_unit_ids:
		var xform : TransformComponent = _world.get_component(id, TransformComponent)
		if xform == null:
			continue
		var distance := xform.position.distance_to(position)
		if distance < closest_distance:
			closest_distance = distance
			closest_id = id
	return closest_id

## Called when a placed unit dies. Stops tracking it and returns the card
## that placed it (or null), so the caller can decide what to do with it.
func release_unit(entity_id : int) -> CardResource:
	if entity_id not in placed_unit_ids:
		return null
	placed_unit_ids.erase(entity_id)
	var card : CardResource = placed_unit_cards.get(entity_id)
	placed_unit_cards.erase(entity_id)
	return card
