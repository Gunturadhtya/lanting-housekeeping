class_name EntityLifecycleHandler
extends RefCounted

signal player_died
signal scrap_awarded(amount : int)

var _world : ECSWorld
var _player_id : int
var _deck : Deck
var _unit_placement : UnitPlacementService
var _selection : UnitSelectionController
var _slots : SlotEconomy

func _init(
	world : ECSWorld,
	player_id : int,
	deck : Deck,
	unit_placement : UnitPlacementService,
	selection : UnitSelectionController,
	slots : SlotEconomy
) -> void:
	_world = world
	_player_id = player_id
	_deck = deck
	_unit_placement = unit_placement
	_selection = selection
	_slots = slots
	world.entity_died.connect(_on_entity_died)

func _on_entity_died(entity_id : int) -> void:
	if entity_id == _player_id:
		player_died.emit()
		return

	if _world.has_component(entity_id, ScrapRewardComponent):
		var reward : ScrapRewardComponent = _world.get_component(entity_id, ScrapRewardComponent)
		scrap_awarded.emit(reward.amount)

	var returned_card := _unit_placement.release_unit(entity_id)
	if returned_card:
		_slots.lose(returned_card.unit_slot_cost)

	_selection.clear_selection_if(entity_id)
	_destroy(entity_id)

func _destroy(entity_id : int) -> void:
	var node := _world.get_node(entity_id)
	_world.destroy_entity(entity_id)
	if node and is_instance_valid(node):
		node.queue_free()
