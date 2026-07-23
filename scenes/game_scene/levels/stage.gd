extends Node

signal level_lost
signal level_won(level_path : String)
@warning_ignore("unused_signal")
signal level_changed(level_path : String)

@export_file("*.tscn") var next_level_path : String
@export var enemy_scene : PackedScene
@export var spawn_interval : float = 1.5
@export var enemies_count : int = 5

@onready var player : PlayerEntity = %Player
@onready var spawn_points : Node2D = %SpawnPoints
@onready var health_label : Label = %HealthLabel
@onready var spawn_timer : Timer = %SpawnTimer

var world := ECSWorld.new()
var systems : Array[ECSSystem] = []
var player_id : int = -1
var scrap : int = 0
var enemies_spawned : int = 0
var enemies_alive : int = 0
var game_over : bool = false

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

	_update_health_bar()
	spawn_timer.start(spawn_interval)

func _physics_process(delta : float) -> void:
	if game_over:
		return
	for system in systems:
		system.process(world, delta)
	_update_health_bar()

func _on_spawn_timer_timeout() -> void:
	_spawn_enemy()
	enemies_spawned += 1
	if enemies_spawned >= enemies_count:
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

func _on_entity_died(entity_id : int) -> void:
	if entity_id == player_id:
		if not game_over:
			game_over = true
			level_lost.emit()
		return
	var node := world.get_node(entity_id)
	world.destroy_entity(entity_id)
	if node and is_instance_valid(node):
		node.queue_free()

func _update_health_bar() -> void:
	var health := player.get_health()
	health_label.text = "HP: %d/%d" % [health.current, health.max]
