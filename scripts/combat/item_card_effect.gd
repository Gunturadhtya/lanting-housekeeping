class_name ItemCardEffect
extends RefCounted

static func apply(world : ECSWorld, card : CardResource, target_position : Vector2) -> void:
	for id in world.query([TransformComponent, FactionComponent, HealthComponent]):
		var faction : FactionComponent = world.get_component(id, FactionComponent)
		if faction.type != FactionComponent.FactionType.ENEMY:
			continue
		var xform : TransformComponent = world.get_component(id, TransformComponent)
		if xform.position.distance_to(target_position) > card.item_radius:
			continue
		var health : HealthComponent = world.get_component(id, HealthComponent)
		health.current = maxi(0, health.current - card.item_damage)
