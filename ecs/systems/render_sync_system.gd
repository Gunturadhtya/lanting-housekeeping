class_name RenderSyncSystem
extends ECSSystem

func process(world : ECSWorld, _delta : float) -> void:
	for id in world.query([TransformComponent]):
		var node := world.get_node(id)
		if node == null or not is_instance_valid(node):
			continue
		var xform : TransformComponent = world.get_component(id, TransformComponent)
		node.position = xform.position
		node.rotation = xform.rotation
