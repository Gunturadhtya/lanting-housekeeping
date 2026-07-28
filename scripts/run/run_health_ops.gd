class_name RunHealthOps
extends RefCounted

static func sync(state : RunManager, current : int, max_hp_value : int) -> void:
	state.current_hp = current
	state.max_hp = max_hp_value

static func apply_damage(state : RunManager, amount : int) -> int:
	state.current_hp = maxi(0, state.current_hp - amount)
	return state.current_hp

static func heal(state : RunManager, amount : int) -> int:
	state.current_hp = mini(state.max_hp, state.current_hp + amount)
	return state.current_hp

static func is_alive(state : RunManager) -> bool:
	return state.current_hp > 0
