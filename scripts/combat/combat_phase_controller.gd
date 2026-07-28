class_name CombatPhaseController
extends RefCounted

enum Phase { PREPARATION, COMBAT }

signal phase_changed(phase : int)

var phase : int = Phase.PREPARATION

func is_preparation() -> bool:
	return phase == Phase.PREPARATION

func is_combat() -> bool:
	return phase == Phase.COMBAT

func set_phase(new_phase : int) -> void:
	phase = new_phase
	phase_changed.emit(phase)

func toggle() -> void:
	set_phase(Phase.COMBAT if is_preparation() else Phase.PREPARATION)
