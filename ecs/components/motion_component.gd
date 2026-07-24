class_name MotionComponent extends RefCounted

var speed: float
var velocity: Vector2
var destination: Vector2
var home_destination: Vector2

func _init(speed: float, velocity: Vector2 = Vector2.ZERO, destination: Vector2 = Vector2.INF):
	self.speed = speed
	self.velocity = velocity
	self.destination = destination
	self.home_destination = destination
