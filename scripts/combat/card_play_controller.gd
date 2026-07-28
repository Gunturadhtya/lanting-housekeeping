class_name CardPlayController
extends RefCounted

signal unit_placed(entity_id : int, card : CardResource)

var _phase_controller : CombatPhaseController
var _unit_placement : UnitPlacementService
var _world : ECSWorld
var _hand_ui : HandUI
var _drop_zone : DropZoneValidator

func _init(
	phase_controller : CombatPhaseController,
	unit_placement : UnitPlacementService,
	world : ECSWorld,
	hand_ui : HandUI,
	drop_zone : DropZoneValidator
) -> void:
	_phase_controller = phase_controller
	_unit_placement = unit_placement
	_world = world
	_hand_ui = hand_ui
	_drop_zone = drop_zone

func handle_play(card : CardResource, drop_global_position : Vector2, card_ui : CardUI) -> void:
	if not _drop_zone.is_within_battlefield(drop_global_position):
		_hand_ui.cancel_play(card_ui)
		return

	if card.type == CardResource.CardType.UNIT:
		if not _phase_controller.is_preparation():
			_hand_ui.cancel_play(card_ui)
			return
		var entity_id := _unit_placement.place_unit(card, drop_global_position)
		if entity_id == -1:
			_hand_ui.cancel_play(card_ui)
			return
		unit_placed.emit(entity_id, card)
		_hand_ui.confirm_play(card_ui)
	else:
		if not _phase_controller.is_combat():
			_hand_ui.cancel_play(card_ui)
			return
		ItemCardEffect.apply(_world, card, drop_global_position)
		_hand_ui.confirm_play(card_ui)
