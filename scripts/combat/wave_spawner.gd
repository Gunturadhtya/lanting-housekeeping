class_name WaveSpawner
extends RefCounted

signal wave_started(wave : int, total_waves : int)
signal wave_cleared(wave : int)
signal all_waves_cleared

var total_waves : int
var current_wave : int = 0

var _world : ECSWorld
var _parent : Node
var _enemy_scene : PackedScene
var _spawn_points : Node2D
var _spawn_timer : Timer
var _target_node : Node2D
var _spawn_interval : float
var _enemies_per_wave : int

var _enemies_spawned_this_wave : int = 0
var _enemies_alive : int = 0

func _init(
	world : ECSWorld,
	parent : Node,
	enemy_scene : PackedScene,
	spawn_points : Node2D,
	spawn_timer : Timer,
	target_node : Node2D,
	spawn_interval : float,
	enemies_per_wave : int,
	total_waves_ : int
) -> void:
	_world = world
	_parent = parent
	_enemy_scene = enemy_scene
	_spawn_points = spawn_points
	_spawn_timer = spawn_timer
	_target_node = target_node
	_spawn_interval = spawn_interval
	_enemies_per_wave = enemies_per_wave
	total_waves = total_waves_
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func start_next_wave() -> void:
	current_wave += 1
	_enemies_spawned_this_wave = 0
	_spawn_timer.start(_spawn_interval)
	wave_started.emit(current_wave, total_waves)

func has_more_waves() -> bool:
	return current_wave < total_waves

func _on_spawn_timer_timeout() -> void:
	_spawn_enemy()
	_enemies_spawned_this_wave += 1
	if _enemies_spawned_this_wave >= _enemies_per_wave:
		_spawn_timer.stop()

func _spawn_enemy() -> void:
	var points := _spawn_points.get_children()
	if points.is_empty() or _enemy_scene == null:
		return
	var spawn_point : Node2D = points[randi() % points.size()]
	var enemy : EnemyEntity = _enemy_scene.instantiate()
	_parent.add_child(enemy)
	enemy.position = spawn_point.position
	enemy.setup(_world, _target_node.position)
	_enemies_alive += 1
	enemy.tree_exited.connect(_on_enemy_node_freed, CONNECT_ONE_SHOT)

func _on_enemy_node_freed() -> void:
	_enemies_alive -= 1
	if _enemies_alive > 0 or _enemies_spawned_this_wave < _enemies_per_wave:
		return
	if has_more_waves():
		wave_cleared.emit(current_wave)
	else:
		all_waves_cleared.emit()
