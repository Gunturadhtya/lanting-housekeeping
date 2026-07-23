class_name PlayerEntity
extends ECSEntity

@export var max_health : int = 100

func setup(ecs_world : ECSWorld) -> void:
	_register(ecs_world)
	world.add_component(entity_id, HealthComponent.new(max_health, max_health))
	world.add_component(entity_id, FactionComponent.new(FactionComponent.Type.PLAYER))

func get_health() -> HealthComponent:
	if entity_id == -1:
		return null
	return world.get_component(entity_id, HealthComponent)
