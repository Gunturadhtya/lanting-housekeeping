class_name PlayerUnitEntity
extends ECSEntity

@export var max_health : int = 30
@export var move_speed : float = 90.0
@export var sensor_radius : float = 220.0
@export var sensor_fov_degrees : float = 80.0
@export var attack_damage : int = 10
@export var attack_range : float = 200.0
@export var attack_cooldown : float = 1.0
@export var show_debug_cone : bool = true

var _selected : bool = false

const HEALTH_BAR_WIDTH := 40.0
const HEALTH_BAR_HEIGHT := 6.0
const HEALTH_BAR_Y_OFFSET := -34.0

func setup(ecs_world : ECSWorld) -> void:
	_register(ecs_world)
	world.add_component(entity_id, HealthComponent.new(max_health, max_health))
	world.add_component(entity_id, FactionComponent.new(FactionComponent.FactionType.PLAYER))
	world.add_component(entity_id, MotionComponent.new(move_speed, Vector2.ZERO, position))
	world.add_component(entity_id, ConeSensorComponent.new(sensor_radius, sensor_fov_degrees))
	world.add_component(entity_id, CombatComponent.new(attack_damage, attack_range, attack_cooldown))
	queue_redraw()

func move_to(target_position : Vector2) -> void:
	if entity_id == -1:
		return
	var motion : MotionComponent = world.get_component(entity_id, MotionComponent)
	if motion:
		motion.destination = target_position

func set_selected(value : bool) -> void:
	_selected = value
	queue_redraw()

func _process(_delta : float) -> void:
	queue_redraw()

func _draw() -> void:
	if entity_id == -1 or world == null:
		return
	
	if _selected:
		draw_circle(Vector2.ZERO, 20.0, Color(1, 1, 0, 0.35))

	if show_debug_cone:
		var sensor : ConeSensorComponent = world.get_component(entity_id, ConeSensorComponent)
		if sensor:
			var steps := 12
			var half_fov := deg_to_rad(sensor.fov_degrees * 0.5)
			var points := PackedVector2Array([Vector2.ZERO])
			for i in range(steps + 1):
				var angle := -half_fov + (2.0 * half_fov) * (float(i) / steps)
				points.append(Vector2.RIGHT.rotated(angle) * sensor.radius)
			draw_colored_polygon(points, Color(0.25, 0.65, 1.0, 0.12))
	
	var health : HealthComponent = world.get_component(entity_id, HealthComponent)
	if health == null:
		return
	draw_set_transform(Vector2.ZERO, -rotation, Vector2.ONE)
	var top_left := Vector2(-HEALTH_BAR_WIDTH * 0.5, HEALTH_BAR_Y_OFFSET)
	var ratio : float = clampf(float(health.current) / float(maxi(health.max, 1)), 0.0, 1.0)
	draw_rect(Rect2(top_left, Vector2(HEALTH_BAR_WIDTH, HEALTH_BAR_HEIGHT)), Color(0, 0, 0, 0.6))
	draw_rect(Rect2(top_left, Vector2(HEALTH_BAR_WIDTH * ratio, HEALTH_BAR_HEIGHT)), Color(0.25, 0.9, 0.35, 1.0))
	draw_rect(Rect2(top_left, Vector2(HEALTH_BAR_WIDTH, HEALTH_BAR_HEIGHT)), Color(0, 0, 0, 1.0), false, 1.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
