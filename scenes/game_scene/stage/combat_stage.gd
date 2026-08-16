extends Node

signal level_lost
signal level_won(level_path : String)
@warning_ignore("unused_signal")
signal level_changed(level_path : String)

@export var debug : bool
@export_file("*.tscn") var next_level_path : String
@export var enemy_scene : PackedScene
@export var spawn_interval : float = 1.5
@export var enemies_per_wave : int = 5
@export var total_waves : int = 3

@export var hand_size : int = 4
@export var hand_area_height : float = 190.0
@export var reward_card_pool : Array[CardResource] = []

@onready var reward_phase : RewardPhase = %RewardPhase
@onready var player : PlayerEntity = %Player
@onready var spawn_points : Node2D = %SpawnPoints
@onready var health_label : Label = %HealthLabel
@onready var spawn_timer : Timer = %SpawnTimer
@onready var hand_ui : HandUI = %HandUI
@onready var phase_button : Button = %PhaseButton
@onready var phase_label : Label = %PhaseLabel
@onready var deck_label : Button = %DeckLabel
@onready var drag_layer : CanvasLayer = %DragLayer
@onready var wave_label : Label = %WaveLabel
@onready var deck_view_ui : DeckViewUI = %DeckViewUI
@onready var scrap_label : Label = %ScrapLabel
@onready var drop_preview : CardDropPreview = %DropPreview
@onready var energy_label : Label = %EnergyLabel
@onready var slot_label : Label = %SlotLabel

var world := ECSWorld.new()
var systems : Array[ECSSystem] = []

var _deck : Deck
var _player_id : int = -1
var _game_over : bool = false

var _phase_controller : CombatPhaseController
var _wave_spawner : WaveSpawner
var _unit_placement : UnitPlacementService
var _selection : UnitSelectionController
var _card_play : CardPlayController
var _lifecycle : EntityLifecycleHandler
var _scrap : ScrapEconomy
var _energy : EnergyEconomy
var _slots : SlotEconomy
var _hud : CombatHud
var _reward : RewardCoordinator

func _ready() -> void:
	systems = [
		MotionSystem.new(),
		ConeSensorSystem.new(),
		CombatSystem.new(),
		HealthSystem.new(),
		RenderSyncSystem.new(),
	]

	player.setup(world)
	_player_id = player.entity_id

	_deck = Deck.new(_get_starting_deck())
	_deck.deck_changed.connect(_update_deck_label)
	hand_ui.hand_size = hand_size
	hand_ui.card_play_requested.connect(_on_card_play_requested)
	drop_preview.world = world
	hand_ui.card_drag_started.connect(_on_card_drag_started)
	hand_ui.card_drag_updated.connect(_on_card_drag_updated)
	hand_ui.card_drag_ended.connect(_on_card_drag_ended)
	deck_label.pressed.connect(_on_deck_label_pressed)

	_build_controllers()
	
	hand_ui.setup(_deck, drag_layer)
	_deck.set_hand_provider(hand_ui.get_cards_in_hand)

	level_won.connect(_on_combat_won)
	level_lost.connect(_on_combat_lost)
	phase_button.pressed.connect(_on_phase_button_pressed)

	_apply_phase(_phase_controller.phase)
	_update_health_bar()
	_update_deck_label()

func _build_controllers() -> void:
	_phase_controller = CombatPhaseController.new()
	_phase_controller.phase_changed.connect(_apply_phase)

	_wave_spawner = WaveSpawner.new(
		world, self, enemy_scene, spawn_points, spawn_timer, player,
		spawn_interval, enemies_per_wave, total_waves
	)
	_wave_spawner.wave_started.connect(_hud_show_wave)
	_wave_spawner.wave_cleared.connect(_on_wave_cleared)
	_wave_spawner.all_waves_cleared.connect(_on_all_waves_cleared)

	_unit_placement = UnitPlacementService.new(world, self)

	var drop_zone := DropZoneValidator.new(self, hand_area_height)

	_selection = UnitSelectionController.new(world, _unit_placement, _phase_controller, drop_zone)

	_scrap = ScrapEconomy.new()
	_scrap.scrap_changed.connect(_hud_show_scrap)
	
	_energy = EnergyEconomy.new()
	_energy.energy_changed.connect(_hud_show_energy)

	_slots = SlotEconomy.new()
	_slots.slots_changed.connect(_hud_show_slots)

	_card_play = CardPlayController.new(_phase_controller, _unit_placement, world, hand_ui, drop_zone, _scrap, _energy, _slots)

	_lifecycle = EntityLifecycleHandler.new(world, _player_id, _deck, _unit_placement, _selection, _slots)
	_lifecycle.player_died.connect(_on_player_died)
	_lifecycle.scrap_awarded.connect(_on_scrap_awarded)
	_selection.unit_retracted.connect(_lifecycle.retract_unit)

	_hud = CombatHud.new(health_label, deck_label, wave_label, scrap_label, energy_label, slot_label, phase_label, phase_button)

	_reward = RewardCoordinator.new(reward_phase, _deck, next_level_path)
	_reward.victory_confirmed.connect(func(path : String) -> void: level_won.emit(path))
	_scrap.initialize()
	_energy.initialize()
	_slots.initialize()

func _get_starting_deck() -> Array[CardResource]:
	var run_deck := RunManager.get_deck()
	return run_deck

func _physics_process(delta : float) -> void:
	if _game_over:
		return
	_energy.process(delta)
	for system in systems:
		system.process(world, delta)
	_update_health_bar()

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_selection.handle_press(event.global_position)
		else:
			_selection.handle_release(event.global_position)
	elif event is InputEventMouseMotion:
		_selection.handle_motion(event.global_position)
	elif event is InputEventScreenTouch:
		if event.pressed:
			_selection.handle_press(event.position)
		else:
			_selection.handle_release(event.position)
	elif event is InputEventScreenDrag:
		_selection.handle_motion(event.position)
## Phase

func _on_phase_button_pressed() -> void:
	_phase_controller.toggle()

func _apply_phase(phase : int) -> void:
	_hud.show_phase(phase)
	if phase == CombatPhaseController.Phase.PREPARATION:
		_energy.end_phase()
		hand_ui.discard_cards_of_type(CardResource.CardType.ITEM)
		hand_ui.show_unit_cards()
		hand_ui.set_playable_type(CardResource.CardType.UNIT)
		_deck.set_active_type(CardResource.CardType.UNIT)
	else:
		_selection.cancel_drag()
		if !debug:
			phase_button.visible = false
		_energy.begin_phase()
		hand_ui.discard_cards_of_type(CardResource.CardType.UNIT)
		hand_ui.set_playable_type(CardResource.CardType.ITEM)
		_deck.set_active_type(CardResource.CardType.ITEM)
		_wave_spawner.start_next_wave()
	hand_ui.refill_hand()

## Card plays

func _on_card_play_requested(card : CardResource, drop_global_position : Vector2, card_ui : CardUI) -> void:
	_card_play.handle_play(card, drop_global_position, card_ui)

func _on_card_drag_started(card : CardResource, global_position : Vector2) -> void:
	if card.type != CardResource.CardType.ITEM or not _phase_controller.is_combat():
		return
	drop_preview.begin(card, global_position)

func _on_card_drag_updated(card : CardResource, global_position : Vector2) -> void:
	drop_preview.update_target(global_position)

func _on_card_drag_ended(_card : CardResource) -> void:
	drop_preview.finish()

## Waves

func _on_wave_cleared(_wave : int) -> void:
	if _game_over:
		return
	_phase_controller.set_phase(CombatPhaseController.Phase.PREPARATION)
	phase_button.visible = true

func _on_all_waves_cleared() -> void:
	if _game_over:
		return
	_game_over = true
	_reward.show_victory_reward(reward_card_pool)

## Entity lifecycle

func _on_player_died() -> void:
	if _game_over:
		return
	_game_over = true
	call_deferred("emit_signal", "level_lost")

func _on_scrap_awarded(amount : int) -> void:
	_scrap.collect(amount)

## HUD

func _update_health_bar() -> void:
	var health := player.get_health()
	if health:
		_hud.show_health(health.current, health.max)
		if RunManager.has_active_run():
			RunManager.sync_hp(health.current, health.max)

func _update_deck_label() -> void:
	_hud.show_deck(_deck.draw_count(), _deck.discard_count())

func _hud_show_scrap(amount : int) -> void:
	_hud.show_scrap(amount)

func _hud_show_wave(wave : int, total : int) -> void:
	_hud.show_wave(wave, total)

func _hud_show_energy(current: int, max_energy: int):
	_hud.show_energy(current, max_energy)

func _hud_show_slots(used: int, max_slot: int):
	_hud.show_slots(used, max_slot)

func _on_deck_label_pressed() -> void:
	deck_view_ui.show_cards(_deck.get_all_cards())

## Scene transitions

func _on_combat_won(_next_level_path : String) -> void:
	CombatSceneTransitions.go_to_map()

func _on_combat_lost() -> void:
	CombatSceneTransitions.go_to_main_menu()
