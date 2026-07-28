class_name RunScrapOps
extends RefCounted

static func add(state : RunManager, amount : int) -> void:
	state.scrap += amount

static func spend(state : RunManager, amount : int) -> bool:
	if state.scrap < amount:
		return false
	state.scrap -= amount
	return true
