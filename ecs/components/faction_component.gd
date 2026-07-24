class_name FactionComponent extends RefCounted

enum FactionType { PLAYER, ENEMY }
var type: int

func _init(type: int):
	self.type = type
