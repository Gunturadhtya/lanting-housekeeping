extends Node

signal level_lost
signal level_won(level_path : String)
@warning_ignore("unused_signal")
signal level_changed(level_path : String)

enum Phase { PREPARATION, COMBAT }

@export_file("*.tscn") var next_level_path : String
@export var enemy_scene : PackedScene
@export var spawn_interval : float = 1.5
@export var enemies_per_wave : int = 5
@export var total_waves : int = 3

@export var starting_deck : Array[CardResource] = []
@export var hand_size : int = 4
@export var hand_area_height : float = 190.0

@onready var player : PlayerEntity = %Player
@onready var spawn_points : Node2D = %SpawnPoints
@onready var health_label : Label = %HealthLabel
@onready var spawn_timer : Timer = %SpawnTimer
@onready var hand_ui : HandUI = %HandUI
@onready var phase_button : Button = %PhaseButton
@onready var phase_label : Label = %PhaseLabel
@onready var deck_label : Label = %DeckLabel
@onready var drag_layer : CanvasLayer = %DragLayer
@onready var wave_label : Label = %WaveLabel

var world := ECSWorld.new()
var systems : Array[ECSSystem] = []
var player_id : int = -1
var scrap : int = 0
var current_wave : int = 0
var enemies_spawned_this_wave : int = 0
var enemies_alive : int = 0
var game_over : bool = false

var deck : Deck
var phase : int = Phase.PREPARATION
var selected_unit_id : int = -1
var placed_unit_ids : Array[int] = []
var placed_unit_cards : Dictionary = {} 

func _ready() -> void:
	systems = [
		MotionSystem.new(),
		ConeSensorSystem.new(),
		CombatSystem.new(),
		HealthSystem.new(),
		RenderSyncSystem.new(),
	]
	world.entity_died.connect(_on_entity_died)
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

	player.setup(world)
	player_id = player.entity_id

	deck = Deck.new(starting_deck)
	deck.deck_changed.connect(_update_deck_label)
	hand_ui.hand_size = hand_size
	hand_ui.setup(deck, drag_layer)
	hand_ui.card_play_requested.connect(_on_card_play_requested)

	phase_button.pressed.connect(_on_phase_button_pressed)
	_set_phase(Phase.PREPARATION)

	_update_health_bar()
	_update_deck_label()

func _physics_process(delta : float) -> void:
	if game_over:
		return
	if phase == Phase.COMBAT:
		for system in systems:
			system.process(world, delta)
	_update_health_bar()
	

func _start_wave() -> void:
	current_wave += 1
	enemies_spawned_this_wave = 0
	wave_label.text = "Wave %d / %d" % [current_wave, total_waves]
	spawn_timer.start(spawn_interval)

## Phases
func _on_phase_button_pressed() -> void:
	if phase == Phase.PREPARATION:
		_set_phase(Phase.COMBAT)
	else:
		_set_phase(Phase.PREPARATION)

func _set_phase(new_phase : int) -> void:
	phase = new_phase
	selected_unit_id = -1
	if phase == Phase.PREPARATION:
		phase_label.text = "Preparation Phase"
		phase_button.text = "Start Combat"
		hand_ui.set_playable_type(CardResource.CardType.UNIT)
		deck.set_active_type(CardResource.CardType.UNIT)
	else:
		phase_label.text = "Combat Phase"
		phase_button.text = "Back to Prep"
		hand_ui.set_playable_type(CardResource.CardType.ITEM)
		deck.set_active_type(CardResource.CardType.ITEM)
		enemies_spawned_this_wave = 0
		_start_wave()
	hand_ui.refill_hand()

## Card plays
func _on_card_play_requested(card : CardResource, drop_global_position : Vector2, card_ui : CardUI) -> void:
	if not _is_valid_drop(drop_global_position):
		hand_ui.cancel_play(card_ui)
		return

	if card.type == CardResource.CardType.UNIT:
		if phase != Phase.PREPARATION:
			hand_ui.cancel_play(card_ui)
			return
		_spawn_player_unit(card, drop_global_position)
		hand_ui.confirm_play(card_ui)
	else:
		if phase != Phase.COMBAT:
			hand_ui.cancel_play(card_ui)
			return
		_use_item_card(card, drop_global_position)
		hand_ui.confirm_play(card_ui)

func _is_valid_drop(world_position : Vector2) -> bool:
	var viewport_size := get_viewport().get_visible_rect().size
	if world_position.y < 0.0 or world_position.y > viewport_size.y - hand_area_height:
		return false
	if world_position.x < 0.0 or world_position.x > viewport_size.x:
		return false
	return true

func _spawn_player_unit(card : CardResource, drop_position : Vector2) -> void:
	if card.unit_scene == null:
		return
	var unit : PlayerUnitEntity = card.unit_scene.instantiate()
	unit.max_health = card.unit_max_health
	unit.move_speed = card.unit_move_speed
	unit.sensor_radius = card.unit_sensor_radius
	unit.sensor_fov_degrees = card.unit_sensor_fov_degrees
	unit.attack_damage = card.unit_attack_damage
	unit.attack_range = card.unit_attack_range
	unit.attack_cooldown = card.unit_attack_cooldown
	add_child(unit)
	unit.position = drop_position
	unit.setup(world)
	placed_unit_ids.append(unit.entity_id)
	placed_unit_cards[unit.entity_id] = card

func _use_item_card(card : CardResource, target_position : Vector2) -> void:
	for id in world.query([TransformComponent, FactionComponent, HealthComponent]):
		var faction : FactionComponent = world.get_component(id, FactionComponent)
		if faction.type != FactionComponent.FactionType.ENEMY:
			continue
		var xform : TransformComponent = world.get_component(id, TransformComponent)
		if xform.position.distance_to(target_position) <= card.item_radius:
			var health : HealthComponent = world.get_component(id, HealthComponent)
			health.current = maxi(0, health.current - card.item_damage)

## Enemies
func _on_spawn_timer_timeout() -> void:
	_spawn_enemy()
	enemies_spawned_this_wave += 1
	if enemies_spawned_this_wave >= enemies_per_wave:
		spawn_timer.stop()

func _spawn_enemy() -> void:
	var points := spawn_points.get_children()
	if points.is_empty() or enemy_scene == null:
		return
	var spawn_point : Node2D = points[randi() % points.size()]
	var enemy : EnemyEntity = enemy_scene.instantiate()
	add_child(enemy)
	enemy.position = spawn_point.position
	enemy.setup(world, player.position)
	enemies_alive += 1
	enemy.tree_exited.connect(_on_enemy_node_freed, CONNECT_ONE_SHOT)

func _on_enemy_node_freed() -> void:
	enemies_alive -= 1
	if game_over:
		return
	if enemies_alive <= 0 and enemies_spawned_this_wave >= enemies_per_wave:
		if current_wave >= total_waves:
			level_won.emit(next_level_path)
		else:
			_start_wave()

func _on_entity_died(entity_id : int) -> void:
	if entity_id == player_id:
		if not game_over:
			game_over = true
			level_lost.emit()
		return
	if entity_id in placed_unit_ids:
		placed_unit_ids.erase(entity_id)
		var card : CardResource = placed_unit_cards.get(entity_id)
		if card:
			deck.return_card_to_draw(card)
			placed_unit_cards.erase(entity_id)
	if selected_unit_id == entity_id:
		selected_unit_id = -1
	var node := world.get_node(entity_id)
	world.destroy_entity(entity_id)
	if node and is_instance_valid(node):
		node.queue_free()

func _update_health_bar() -> void:
	var health := player.get_health()
	if health:
		health_label.text = "HP: %d/%d" % [health.current, health.max]

func _update_deck_label() -> void:
	if deck_label:
		deck_label.text = "Deck: %d  Discard: %d" % [deck.draw_count(), deck.discard_count()]

## Point-and-click
func _unhandled_input(event : InputEvent) -> void:
	if phase != Phase.COMBAT:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_battlefield_click(event.global_position)

func _handle_battlefield_click(click_position : Vector2) -> void:
	if not _is_valid_drop(click_position):
		return
	var clicked_unit_id := _find_unit_at(click_position)
	if clicked_unit_id != -1:
		selected_unit_id = clicked_unit_id
		return
	if selected_unit_id != -1:
		var node := world.get_node(selected_unit_id)
		if node and node.has_method("move_to"):
			node.move_to(click_position)
		selected_unit_id = -1

func _find_unit_at(click_position : Vector2, max_distance : float = 32.0) -> int:
	var closest_id := -1
	var closest_distance := max_distance
	for id in placed_unit_ids:
		var xform : TransformComponent = world.get_component(id, TransformComponent)
		if xform == null:
			continue
		var distance := xform.position.distance_to(click_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_id = id
	return closest_id
