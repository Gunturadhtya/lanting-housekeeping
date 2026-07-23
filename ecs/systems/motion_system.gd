class_name MotionSystem
extends ECSSystem

func process(world : ECSWorld, delta : float) -> void:
	for id in world.query([MotionComponent, TransformComponent]):
		var motion : MotionComponent = world.get_component(id, MotionComponent)
		var xform : TransformComponent = world.get_component(id, TransformComponent)
		if motion.destination == Vector2.INF:
			continue
		var offset := motion.destination - xform.position
		var distance := offset.length()
		if distance <= 2.0:
			motion.velocity = Vector2.ZERO
			continue
		var direction := offset / distance
		motion.velocity = direction * motion.speed
		xform.position += motion.velocity * delta
		xform.rotation = direction.angle()
