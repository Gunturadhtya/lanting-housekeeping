class_name ConeSensorSystem
extends ECSSystem

func process(world : ECSWorld, _delta : float) -> void:
	var sensors := world.query([ConeSensorComponent, TransformComponent, FactionComponent])
	var candidates := world.query([TransformComponent, FactionComponent, HealthComponent])
	for sensor_id in sensors:
		var sensor : ConeSensorComponent = world.get_component(sensor_id, ConeSensorComponent)
		var sensor_xform : TransformComponent = world.get_component(sensor_id, TransformComponent)
		var sensor_faction : FactionComponent = world.get_component(sensor_id, FactionComponent)
		var combat : CombatComponent = world.get_component(sensor_id, CombatComponent)
		var motion : MotionComponent = world.get_component(sensor_id, MotionComponent)
		var is_stationary := motion == null or motion.velocity.is_equal_approx(Vector2.ZERO)
		var forward := Vector2.RIGHT.rotated(sensor_xform.rotation)
		var half_fov := sensor.fov_degrees * 0.5
		var best_id := -1
		var best_distance := INF
		for target_id in candidates:
			if target_id == sensor_id:
				continue
			var target_faction : FactionComponent = world.get_component(target_id, FactionComponent)
			if target_faction.type == sensor_faction.type:
				continue
			var target_xform : TransformComponent = world.get_component(target_id, TransformComponent)
			var offset := target_xform.position - sensor_xform.position
			var distance := offset.length()
			if distance > sensor.radius:
				continue
			if distance > 0.0 and rad_to_deg(absf(forward.angle_to(offset))) > half_fov:
				continue
			if distance < best_distance:
				best_distance = distance
				best_id = target_id
		if best_id != -1 and is_stationary:
			var target_xform : TransformComponent = world.get_component(best_id, TransformComponent)
			sensor_xform.rotation = (target_xform.position - sensor_xform.position).angle()
		if combat:
			combat.target_id = best_id
