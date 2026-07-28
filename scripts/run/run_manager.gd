class_name RunManager
extends Resource

const STATE_NAME : String = "RunManager"
const FILE_PATH : String = "res://scripts/run/run_manager.gd"

@export var in_progress : bool = false
@export var current_hp : int = 0
@export var max_hp : int = 0
@export var scrap : int = 0
@export var deck : Array[CardResource] = []
@export var card_removals : int = 0

@export var map_data : Dictionary = {}
@export var current_node_id : String = ""
@export var visited_node_ids : Array = []
@export var floor_index : int = 0
@export var map_seed : int = 0

static func _state() -> RunManager:
	return GlobalState.get_or_create_state(STATE_NAME, FILE_PATH)

## Run Lifecycle

static func has_active_run() -> bool:
	return GlobalState.has_state(STATE_NAME) and _state().in_progress

static func start_new_run(starting_deck : Array[CardResource], starting_hp : int = 100, run_seed : int = -1) -> void:
	RunLifecycleOps.start_new_run(_state(), starting_deck, starting_hp, run_seed)
	GlobalState.save()

static func end_run() -> void:
	RunLifecycleOps.end(_state())
	GlobalState.save()

static func clear_run() -> void:
	RunLifecycleOps.clear(_state())
	GlobalState.save()

## Health

static func get_hp() -> int:
	return _state().current_hp

static func get_max_hp() -> int:
	return _state().max_hp

static func sync_hp(current : int, max_hp_value : int) -> void:
	RunHealthOps.sync(_state(), current, max_hp_value)
	GlobalState.save()

static func apply_damage(amount : int) -> int:
	var result := RunHealthOps.apply_damage(_state(), amount)
	GlobalState.save()
	return result

static func heal(amount : int) -> int:
	var result := RunHealthOps.heal(_state(), amount)
	GlobalState.save()
	return result

static func is_alive() -> bool:
	return RunHealthOps.is_alive(_state())

## Scrap

static func get_scrap() -> int:
	return _state().scrap

static func add_scrap(amount : int) -> void:
	RunScrapOps.add(_state(), amount)
	GlobalState.save()

static func spend_scrap(amount : int) -> bool:
	var result := RunScrapOps.spend(_state(), amount)
	GlobalState.save()
	return result

## Deck

static func get_deck() -> Array[CardResource]:
	return _state().deck

static func set_deck(cards : Array[CardResource]) -> void:
	RunDeckOps.set_deck(_state(), cards)
	GlobalState.save()

static func add_card(card : CardResource) -> void:
	RunDeckOps.add_card(_state(), card)
	GlobalState.save()

## Shop

static func get_card_removals() -> int:
	return _state().card_removals

static func remove_card(card : CardResource) -> bool:
	var result := RunShopOps.remove_card(_state(), card)
	if result:
		GlobalState.save()
	return result

## Workshop

static func upgrade_card(card : CardResource) -> CardResource:
	var result := RunWorkshopOps.upgrade_card(_state(), card)
	if result:
		GlobalState.save()
	return result

## Map progress

static func get_map_data() -> Dictionary:
	return _state().map_data

static func set_map_data(data : Dictionary) -> void:
	_state().map_data = data
	GlobalState.save()

static func get_current_node_id() -> String:
	return _state().current_node_id

static func set_current_node_id(node_id : String) -> void:
	RunMapProgressOps.set_current_node_id(_state(), node_id)
	GlobalState.save()

static func get_visited_node_ids() -> Array:
	return _state().visited_node_ids

static func get_floor_index() -> int:
	return _state().floor_index

static func set_floor_index(value : int) -> void:
	_state().floor_index = value
	GlobalState.save()

static func get_map_seed() -> int:
	return _state().map_seed
