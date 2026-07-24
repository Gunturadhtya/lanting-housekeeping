class_name CardTypeComponent extends RefCounted

enum CardType { ITEM, UNIT }
var type: int

func _init(type: int):
	self.type = type
