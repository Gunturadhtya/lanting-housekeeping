class_name FactionComponent extends RefCounted

enum Type { PLAYER, ENEMY }
var type: int

func _init(type: int):
	self.type = type
