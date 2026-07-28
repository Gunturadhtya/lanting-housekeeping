class_name RunLifecycleOps
extends RefCounted

static func start_new_run(
	state : RunManager,
	starting_deck : Array[CardResource],
	starting_hp : int,
	run_seed : int
) -> void:
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

static func end(state : RunManager) -> void:
	state.in_progress = false

static func clear(state : RunManager) -> void:
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
