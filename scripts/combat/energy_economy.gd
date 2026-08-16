class_name EnergyEconomy
extends RefCounted

signal energy_changed(current : int, max_energy : int)

const DEFAULT_MAX_ENERGY : int = 5
const DEFAULT_REGEN_INTERVAL_SECONDS : float = 2.0

var max_energy : int = DEFAULT_MAX_ENERGY
var regen_interval_seconds : float = DEFAULT_REGEN_INTERVAL_SECONDS
var energy : int = 0

var _regenerating : bool = false
var _regen_accumulator : float = 0.0

func initialize(starting_max_energy : int = DEFAULT_MAX_ENERGY, starting_regen_interval_seconds : float = DEFAULT_REGEN_INTERVAL_SECONDS) -> void:
	max_energy = starting_max_energy
	regen_interval_seconds = starting_regen_interval_seconds
	energy = 0
	_regenerating = false
	_regen_accumulator = 0.0
	energy_changed.emit(energy, max_energy)

func begin_phase() -> void:
	energy = 0
	_regen_accumulator = 0.0
	_regenerating = true
	energy_changed.emit(energy, max_energy)

func end_phase() -> void:
	_regenerating = false
	_regen_accumulator = 0.0

func process(delta : float) -> void:
	if not _regenerating or energy >= max_energy:
		return
	_regen_accumulator += delta
	while _regen_accumulator >= regen_interval_seconds and energy < max_energy:
		_regen_accumulator -= regen_interval_seconds
		energy += 1
		energy_changed.emit(energy, max_energy)

func can_afford(amount : int) -> bool:
	return energy >= amount

func spend(amount : int) -> bool:
	if not can_afford(amount):
		return false
	energy -= amount
	energy_changed.emit(energy, max_energy)
	return true
 
