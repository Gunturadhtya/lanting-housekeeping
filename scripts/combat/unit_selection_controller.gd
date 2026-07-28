class_name UnitSelectionController
extends RefCounted

signal selection_changed(unit_id : int)

var selected_unit_id : int = -1

var _world : ECSWorld
var _unit_placement : UnitPlacementService
var _phase_controller : CombatPhaseController
var _drop_zone : DropZoneValidator

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

func handle_click(click_position : Vector2) -> void:
	if not _phase_controller.is_preparation():
		return
	if not _drop_zone.is_within_battlefield(click_position):
		return

	var clicked_unit_id := _unit_placement.find_unit_at(click_position)
	if clicked_unit_id != -1:
		_select(clicked_unit_id)
		return

	if selected_unit_id != -1:
		var node := _world.get_node(selected_unit_id)
		if node and node.has_method("move_to"):
			node.move_to(click_position)
		_select(-1)

func clear_selection_if(entity_id : int) -> void:
	if selected_unit_id == entity_id:
		_select(-1)

func _select(unit_id : int) -> void:
	selected_unit_id = unit_id
	_update_selection_indicators()
	selection_changed.emit(selected_unit_id)

func _update_selection_indicators() -> void:
	for id in _unit_placement.placed_unit_ids:
		var node := _world.get_node(id)
		if node and node.has_method("set_selected"):
			node.set_selected(id == selected_unit_id)
