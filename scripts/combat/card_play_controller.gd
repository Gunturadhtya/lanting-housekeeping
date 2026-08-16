class_name CardPlayController
extends RefCounted

signal unit_placed(entity_id : int, card : CardResource)

var _phase_controller : CombatPhaseController
var _unit_placement : UnitPlacementService
var _world : ECSWorld
var _hand_ui : HandUI
var _drop_zone : DropZoneValidator
var _scrap : ScrapEconomy
var _energy : EnergyEconomy
var _slots : SlotEconomy

func _init(
	phase_controller : CombatPhaseController,
	unit_placement : UnitPlacementService,
	world : ECSWorld,
	hand_ui : HandUI,
	drop_zone : DropZoneValidator,
	scrap : ScrapEconomy,
	energy : EnergyEconomy,
	slots : SlotEconomy
) -> void:
	_phase_controller = phase_controller
	_unit_placement = unit_placement
	_world = world
	_hand_ui = hand_ui
	_drop_zone = drop_zone
	_scrap = scrap
	_energy = energy
	_slots = slots

func handle_play(card : CardResource, drop_global_position : Vector2, card_ui : CardUI) -> void:
	if not _drop_zone.is_within_battlefield(drop_global_position):
		_hand_ui.cancel_play(card_ui)
		return

	if card.type == CardResource.CardType.UNIT:
		if not _phase_controller.is_preparation():
			_hand_ui.cancel_play(card_ui)
			return
		if not _scrap.can_afford(card.scrap_cost):
			_hand_ui.cancel_play(card_ui)
			return
		if not _slots.can_afford(card.unit_slot_cost):
			_hand_ui.cancel_play(card_ui)
			return
		var entity_id := _unit_placement.place_unit(card, drop_global_position)
		if entity_id == -1:
			_hand_ui.cancel_play(card_ui)
			return
		_scrap.spend(card.scrap_cost)
		_slots.occupy(card.unit_slot_cost)
		unit_placed.emit(entity_id, card)
		_hand_ui.confirm_play(card_ui)
	else:
		if not _phase_controller.is_combat():
			_hand_ui.cancel_play(card_ui)
			return
		if not _energy.can_afford(card.energy_cost):
			_hand_ui.cancel_play(card_ui)
			return
		_energy.spend(card.energy_cost)
		ItemCardEffect.apply(_world, card, drop_global_position)
		_hand_ui.confirm_play(card_ui)
