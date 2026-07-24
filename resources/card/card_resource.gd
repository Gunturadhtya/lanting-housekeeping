class_name CardResource
extends Resource

enum CardType { ITEM, UNIT }

@export var card_name : String = "Card"
@export var type : CardType = CardType.UNIT
@export var texture : Texture2D
@export var description : String = ""

@export_group("Unit")
@export var unit_scene : PackedScene
@export var unit_max_health : int = 30
@export var unit_move_speed : float = 90.0
@export var unit_sensor_radius : float = 220.0
@export var unit_sensor_fov_degrees : float = 80.0
@export var unit_attack_damage : int = 10
@export var unit_attack_range : float = 200.0
@export var unit_attack_cooldown : float = 1.0

@export_group("Item")
@export var item_damage : int = 20
@export var item_radius : float = 120.0
