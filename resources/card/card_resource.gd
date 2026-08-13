class_name CardResource
extends Resource

enum CardType { ITEM, UNIT }
enum ItemEffectType { DAMAGE, HEAL, CROWD_CONTROL }

@export var card_name : String = "Card"
@export var card_id : String = ""
@export var type : CardType = CardType.UNIT
@export var texture : Texture2D
@export var description : String = ""
@export var scrap_cost : int = 0
@export var energy_cost : int = 1
@export var shop_price : int = 50
@export var upgraded : bool = false

@export_group("Unit")
@export var unit_scene : PackedScene
@export var unit_max_health : int = 30
@export var unit_slot_cost : int = 1
@export var unit_move_speed : float = 90.0
@export var unit_sensor_radius : float = 220.0
@export var unit_sensor_fov_degrees : float = 80.0
@export var unit_attack_damage : int = 10
@export var unit_attack_range : float = 200.0
@export var unit_attack_cooldown : float = 1.0

@export_group("Item")
@export var item_effect_type : ItemEffectType = ItemEffectType.DAMAGE
@export var item_damage : int = 20
@export var item_radius : float = 120.0
@export var item_heal_amount : int = 15
@export var item_slow_multiplier : float = 0.5
@export var item_slow_duration : float = 3.0

const UPGRADE_STAT_MULTIPLIER : float = 1.25
const UPGRADE_COST_REDUCTION : int = 5
const UPGRADE_ENERGY_COST_REDUCTION : int = 1

func create_upgraded() -> CardResource:
	var upgraded_card : CardResource = duplicate(true)
	if upgraded_card.upgraded:
		return upgraded_card
	upgraded_card.upgraded = true
	if not upgraded_card.card_name.ends_with("+"):
		upgraded_card.card_name += "+"
	upgraded_card.scrap_cost = maxi(0, upgraded_card.scrap_cost - UPGRADE_COST_REDUCTION)
	upgraded_card.energy_cost = maxi(1, upgraded_card.energy_cost - UPGRADE_ENERGY_COST_REDUCTION)

	if upgraded_card.type == CardType.UNIT:
		upgraded_card.unit_max_health = int(round(upgraded_card.unit_max_health * UPGRADE_STAT_MULTIPLIER))
		upgraded_card.unit_attack_damage = int(round(upgraded_card.unit_attack_damage * UPGRADE_STAT_MULTIPLIER))
	else:
		match upgraded_card.item_effect_type:
			ItemEffectType.HEAL:
				upgraded_card.item_heal_amount = int(round(upgraded_card.item_heal_amount * UPGRADE_STAT_MULTIPLIER))
			ItemEffectType.CROWD_CONTROL:
				upgraded_card.item_slow_duration *= UPGRADE_STAT_MULTIPLIER
				upgraded_card.item_radius *= UPGRADE_STAT_MULTIPLIER
			_:
				upgraded_card.item_damage = int(round(upgraded_card.item_damage * UPGRADE_STAT_MULTIPLIER))
				upgraded_card.item_radius *= UPGRADE_STAT_MULTIPLIER

	return upgraded_card

func is_unique() -> bool:
	return type == CardType.UNIT
