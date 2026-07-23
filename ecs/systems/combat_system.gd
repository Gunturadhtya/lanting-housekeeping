class_name CombatSystem
extends ECSSystem

func process(world : ECSWorld, delta : float) -> void:
	for id in world.query([CombatComponent, TransformComponent]):
		var combat : CombatComponent = world.get_component(id, CombatComponent)
		combat.timer = maxf(0.0, combat.timer - delta)
		if combat.target_id == -1:
			continue
		if not world.has_component(combat.target_id, TransformComponent) or not world.has_component(combat.target_id, HealthComponent):
			combat.target_id = -1
			continue
		var self_xform : TransformComponent = world.get_component(id, TransformComponent)
		var target_xform : TransformComponent = world.get_component(combat.target_id, TransformComponent)
		if self_xform.position.distance_to(target_xform.position) > combat.attack_range:
			continue
		if combat.timer > 0.0:
			continue
		var target_health : HealthComponent = world.get_component(combat.target_id, HealthComponent)
		target_health.current = maxi(0, target_health.current - combat.damage)
		combat.timer = combat.cooldown
		world.entity_damaged.emit(combat.target_id, combat.damage)
