class_name UnitSelectionController
extends RefCounted

signal selection_changed(unit_id : int)
signal unit_retracted(unit_id : int)

const DRAG_THRESHOLD_PX : float = 8.0

var selected_unit_id : int = -1

var _world : ECSWorld
var _unit_placement : UnitPlacementService
var _phase_controller : CombatPhaseController
var _drop_zone : DropZoneValidator
var _drag_unit_id : int = -1
var _drag_start_position : Vector2 = Vector2.ZERO
var _drag_moved : bool = false

func _init(
	world : ECSWorld,
	unit_placement : UnitPlacementService,
	phase_controller : CombatPhaseController,
	drop_zone : DropZoneValidator
) -> void:
	_world = world
	_unit_placement = unit_placement
	_phase_controller = phase_controller
	_drop_zone = drop_zone

func handle_press(position : Vector2) -> void:
	if selected_unit_id != -1:
		_resolve_selection_action(position)
		return
	if not _drop_zone.is_within_battlefield(position):
		return
	var unit_id := _unit_placement.find_unit_at(position)
	if unit_id == -1:
		return
	
	_drag_unit_id = unit_id
	_drag_start_position = position
	_drag_moved = false
	_select(unit_id)

func handle_motion(position: Vector2) -> void:
	if _drag_unit_id == -1:
		return
	if not _drag_moved and position.distance_to(_drag_start_position) > DRAG_THRESHOLD_PX:
		_drag_moved = true
	if not _drag_moved:
		return
	var node := _world.get_node(_drag_unit_id)
	if node.has_method("set_drag_position"):
		node.set_drag_position(position, _drop_zone.is_within_battlefield(position))

func handle_release(position : Vector2) -> void:
	if _drag_unit_id == -1:
		return
	var _unit_id := _drag_unit_id
	_drag_unit_id = -1
	if not _drag_moved:
		return
	_finalize_move_or_retract(_unit_id, position)
	_select(-1)

func clear_selection_if(entity_id : int) -> void:
	if selected_unit_id == entity_id:
		_select(-1)
	if _drag_unit_id == entity_id:
		_drag_unit_id = -1

func _resolve_selection_action(position : Vector2) -> void:
	var unit_id := selected_unit_id
	if _drop_zone.is_within_battlefield(position):
		var clicked_unit_id := _unit_placement.find_unit_at(position)
		if clicked_unit_id != -1 and clicked_unit_id != unit_id:
			_select(clicked_unit_id)
			return
	_finalize_move_or_retract(unit_id, position)
	_select(-1)

func _finalize_move_or_retract(unit_id : int, position : Vector2) -> void:
	if _drop_zone.is_within_battlefield(position):
		var node := _world.get_node(unit_id)
		if node and node.has_method("move_to"):
			node.move_to(position)
	else:
		unit_retracted.emit(unit_id)

func _select(unit_id : int) -> void:
	selected_unit_id = unit_id
	_update_selection_indicators()
	selection_changed.emit(selected_unit_id)

func _update_selection_indicators() -> void:
	for id in _unit_placement.placed_unit_ids:
		var node := _world.get_node(id)
		if node and node.has_method("set_selected"):
			node.set_selected(id == selected_unit_id)
