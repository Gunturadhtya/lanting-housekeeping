class_name HealthSystem
extends ECSSystem

func process(world : ECSWorld, _delta : float) -> void:
	for id in world.query([HealthComponent]):
		var health : HealthComponent = world.get_component(id, HealthComponent)
		if health.current <= 0:
			world.entity_died.emit(id)
