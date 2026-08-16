class_name CombatHud
extends RefCounted

var _health_label : Label
var _deck_label : Button
var _wave_label : Label
var _scrap_label : Label
var _energy_label: Label
var _slot_label : Label
var _phase_label : Label
var _phase_button : Button

func _init(
	health_label : Label,
	deck_label : Button,
	wave_label : Label,
	scrap_label : Label,
	energy_label : Label,
	slot_label : Label,
	phase_label : Label,
	phase_button : Button
) -> void:
	_health_label = health_label
	_deck_label = deck_label
	_wave_label = wave_label
	_scrap_label = scrap_label
	_energy_label = energy_label
	_slot_label = slot_label
	_phase_label = phase_label
	_phase_button = phase_button

func show_health(current : int, max_health : int) -> void:
	_health_label.text = "HP: %d/%d" % [current, max_health]

func show_deck(draw_count : int, discard_count : int) -> void:
	_deck_label.text = "Deck: %d  Discard: %d" % [draw_count, discard_count]

func show_wave(wave : int, total_waves : int) -> void:
	_wave_label.text = "Wave %d / %d" % [wave, total_waves]

func show_scrap(amount : int) -> void:
	_scrap_label.text = "Scrap: %d" % amount

func show_energy(current: int, max_energy : int) -> void:
	if _energy_label:
		_energy_label.text = "Energy: %d/%d" % [current, max_energy]

func show_phase(phase : int) -> void:
	if phase == CombatPhaseController.Phase.PREPARATION:
		_phase_label.text = "Preparation Phase"
		_phase_button.text = "Start Combat"
	else:
		_phase_label.text = "Combat Phase"
		_phase_button.text = "Back to Prep"

func show_slots(used: int, max_slot: int):
	_slot_label.text = "Slot: %d/%d" % [used, max_slot]
