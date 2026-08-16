class_name SlotEconomy
extends RefCounted

signal slots_changed(used : int, max_slots : int)

const DEFAULT_MAX_SLOTS : int = 5

var max_slots : int = DEFAULT_MAX_SLOTS
var used_slots : int = 0

func initialize(starting_max_slots : int = DEFAULT_MAX_SLOTS) -> void:
	max_slots = starting_max_slots
	used_slots = 0
	slots_changed.emit(used_slots, max_slots)

func can_afford(cost : int) -> bool:
	return cost >= 0 and used_slots + cost <= max_slots

func occupy(cost : int) -> bool:
	if not can_afford(cost):
		return false
	used_slots += cost
	slots_changed.emit(used_slots, max_slots)
	return true

func release(cost : int) -> void:
	used_slots = maxi(0, used_slots - cost)
	slots_changed.emit(used_slots, max_slots)

func lose(cost : int) -> void:
	used_slots = maxi(0, used_slots - cost)
	max_slots = maxi(0, max_slots - cost)
	slots_changed.emit(used_slots, max_slots)
