class_name ECSEntity
extends Node2D

var entity_id : int = -1
var world : ECSWorld

func _register(ecs_world : ECSWorld) -> void:
	world = ecs_world
	entity_id = world.create_entity(self)
	world.add_component(entity_id, TransformComponent.new(position, rotation))

func _exit_tree() -> void:
	if world and entity_id != -1:
		world.destroy_entity(entity_id)
		entity_id = -1
