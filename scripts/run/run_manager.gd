class_name RunManager
extends Resource
const STATE_NAME : String = "RunManager"
const FILE_PATH : String = "res://scripts/run/run_manager.gd"

@export var in_progress : bool = false
@export var current_hp : int = 0
@export var max_hp : int = 0
@export var scrap : int = 0
@export var deck : Array[CardResource] = []

@export var map_data : Dictionary = {}
@export var current_node_id : String = ""
@export var visited_node_ids : Array = []
@export var floor_index : int = 0
@export var map_seed : int = 0

static func _state() -> RunManager:
	return GlobalState.get_or_create_state(STATE_NAME, FILE_PATH)

## ----- Run Lifecycle -----

static func has_active_run() -> bool:
	return GlobalState.has_state(STATE_NAME) and _state().in_progress

static func start_new_run(starting_deck : Array[CardResource], starting_hp : int = 100, run_seed : int = -1) -> void:
	var state := _state()
	state.in_progress = true
	state.max_hp = starting_hp
	state.current_hp = starting_hp
	state.scrap = 0
	state.deck = starting_deck.duplicate()
	state.map_data = {}
	state.current_node_id = ""
	state.visited_node_ids = []
	state.floor_index = 0
	state.map_seed = run_seed if run_seed != -1 else randi()
	GlobalState.save()

static func end_run() -> void:
	var state := _state()
	state.in_progress = false
	GlobalState.save()

static func clear_run() -> void:
	var state := _state()
	state.in_progress = false
	state.current_hp = 0
	state.max_hp = 0
	state.scrap = 0
	state.deck = []
	state.map_data = {}
	state.current_node_id = ""
	state.visited_node_ids = []
	state.floor_index = 0
	state.map_seed = 0
	GlobalState.save()

static func get_hp() -> int:
	return _state().current_hp

static func get_max_hp() -> int:
	return _state().max_hp

static func sync_hp(current : int, max_hp_value : int) -> void:
	var state := _state()
	state.current_hp = current
	state.max_hp = max_hp_value
	GlobalState.save()

static func apply_damage(amount : int) -> int:
	var state := _state()
	state.current_hp = maxi(0, state.current_hp - amount)
	GlobalState.save()
	return state.current_hp

static func heal(amount : int) -> int:
	var state := _state()
	state.current_hp = mini(state.max_hp, state.current_hp + amount)
	GlobalState.save()
	return state.current_hp

static func is_alive() -> bool:
	return _state().current_hp > 0

## ----- Scrap -----

static func get_scrap() -> int:
	return _state().scrap

static func add_scrap(amount : int) -> void:
	var state := _state()
	state.scrap += amount
	GlobalState.save()

static func spend_scrap(amount : int) -> bool:
	var state := _state()
	if state.scrap < amount:
		return false
	state.scrap -= amount
	GlobalState.save()
	return true

## ----- Deck -----

static func get_deck() -> Array[CardResource]:
	return _state().deck

static func set_deck(cards : Array[CardResource]) -> void:
	_state().deck = cards.duplicate()
	GlobalState.save()

static func add_card(card : CardResource) -> void:
	_state().deck.append(card)
	GlobalState.save()

## ----- Map progress -----

static func get_map_data() -> Dictionary:
	return _state().map_data

static func set_map_data(data : Dictionary) -> void:
	_state().map_data = data
	GlobalState.save()

static func get_current_node_id() -> String:
	return _state().current_node_id

static func set_current_node_id(node_id : String) -> void:
	var state := _state()
	state.current_node_id = node_id
	if not node_id.is_empty() and node_id not in state.visited_node_ids:
		state.visited_node_ids.append(node_id)
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
