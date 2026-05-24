class_name CombatComponent extends RefCounted

var damage: int
var attack_range: float
var timer: float
var cooldown: float
var target_id: int

func _init(damage: int, attack_range: float, cooldown: float, initial_timer: float = 0.0):
	self.damage = damage
	self.attack_range = attack_range
	self.cooldown = cooldown
	self.timer = initial_timer
	self.target_id = -1
