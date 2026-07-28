class_name ItemCardEffect
extends RefCounted

static func apply(world : ECSWorld, card : CardResource, target_position : Vector2) -> void:
	match card.item_effect_type:
		CardResource.ItemEffectType.HEAL:
			_apply_heal(world, card, target_position)
		CardResource.ItemEffectType.CROWD_CONTROL:
			_apply_crowd_control(world, card, target_position)
		_:
			_apply_damage(world, card, target_position)

static func _apply_damage(world : ECSWorld, card : CardResource, target_position : Vector2) -> void:
	for id in world.query([TransformComponent, FactionComponent, HealthComponent]):
		var faction : FactionComponent = world.get_component(id, FactionComponent)
		if faction.type != FactionComponent.FactionType.ENEMY:
			continue
		var xform : TransformComponent = world.get_component(id, TransformComponent)
		if xform.position.distance_to(target_position) > card.item_radius:
			continue
		var health : HealthComponent = world.get_component(id, HealthComponent)
		health.current = maxi(0, health.current - card.item_damage)

static func _apply_heal(world : ECSWorld, card : CardResource, target_position : Vector2) -> void:
	var target_id := _find_lock_on_ally(world, target_position)
	if target_id == -1:
		return
	var health : HealthComponent = world.get_component(target_id, HealthComponent)
	if health:
		health.current = mini(health.max, health.current + card.item_heal_amount)

static func _apply_crowd_control(world : ECSWorld, card : CardResource, target_position : Vector2) -> void:
	for id in world.query([TransformComponent, FactionComponent, MotionComponent]):
		var faction : FactionComponent = world.get_component(id, FactionComponent)
		if faction.type != FactionComponent.FactionType.ENEMY:
			continue
		var xform : TransformComponent = world.get_component(id, TransformComponent)
		if xform.position.distance_to(target_position) > card.item_radius:
			continue
		var motion : MotionComponent = world.get_component(id, MotionComponent)
		if motion:
			motion.speed *= card.item_slow_multiplier

static func _find_lock_on_ally(world : ECSWorld, target_position : Vector2, max_distance : float = 220.0) -> int:
	var closest_id := -1
	var closest_distance := max_distance
	for id in world.query([TransformComponent, FactionComponent]):
		var faction : FactionComponent = world.get_component(id, FactionComponent)
		if faction.type != FactionComponent.FactionType.PLAYER:
			continue
		var xform : TransformComponent = world.get_component(id, TransformComponent)
		var distance := xform.position.distance_to(target_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_id = id
	return closest_id
