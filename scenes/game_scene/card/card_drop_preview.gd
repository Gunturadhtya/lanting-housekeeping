class_name CardDropPreview
extends Control

var world : ECSWorld

const LOCK_ON_SEARCH_RADIUS : float = 220.0

var _card : CardResource
var _target_position : Vector2 = Vector2.ZERO
var _locked_unit_id : int = -1

const EFFECT_COLORS := {
	CardResource.ItemEffectType.DAMAGE: Color(1.0, 0.28, 0.2),
	CardResource.ItemEffectType.CROWD_CONTROL: Color(0.3, 0.65, 1.0),
	CardResource.ItemEffectType.HEAL: Color(0.35, 1.0, 0.45),
}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false

func begin(card : CardResource, global_position : Vector2) -> void:
	if card == null or card.type != CardResource.CardType.ITEM:
		return
	_card = card
	visible = true
	_update_target(global_position)

func update_target(global_position : Vector2) -> void:
	if _card == null:
		return
	_update_target(global_position)

func finish() -> void:
	_card = null
	_locked_unit_id = -1
	visible = false
	queue_redraw()

func _update_target(global_position : Vector2) -> void:
	_target_position = global_position
	if _card.item_effect_type == CardResource.ItemEffectType.HEAL:
		_locked_unit_id = _find_lock_on_ally(global_position)
	queue_redraw()

func _find_lock_on_ally(pos : Vector2) -> int:
	if world == null:
		return -1
	var closest_id := -1
	var closest_distance := LOCK_ON_SEARCH_RADIUS
	for id in world.query([TransformComponent, FactionComponent]):
		var faction : FactionComponent = world.get_component(id, FactionComponent)
		if faction.type != FactionComponent.FactionType.PLAYER:
			continue
		var xform : TransformComponent = world.get_component(id, TransformComponent)
		var distance := xform.position.distance_to(pos)
		if distance < closest_distance:
			closest_distance = distance
			closest_id = id
	return closest_id

func _draw() -> void:
	if _card == null:
		return
	match _card.item_effect_type:
		CardResource.ItemEffectType.HEAL:
			_draw_lock_on()
		CardResource.ItemEffectType.CROWD_CONTROL:
			_draw_area(_card.item_radius, EFFECT_COLORS[CardResource.ItemEffectType.CROWD_CONTROL])
		_:
			_draw_area(_card.item_radius, EFFECT_COLORS[CardResource.ItemEffectType.DAMAGE])

func _draw_area(radius : float, color : Color) -> void:
	draw_circle(_target_position, radius, Color(color.r, color.g, color.b, 0.18))
	draw_arc(_target_position, radius, 0.0, TAU, 48, color, 3.0, true)

func _draw_lock_on() -> void:
	var color : Color = EFFECT_COLORS[CardResource.ItemEffectType.HEAL]
	var center := _target_position
	var found_unit := _locked_unit_id != -1 and world != null
	if found_unit:
		var xform : TransformComponent = world.get_component(_locked_unit_id, TransformComponent)
		if xform:
			center = xform.position
		else:
			found_unit = false
	var lock_radius := 34.0 if found_unit else 12.0
	draw_arc(center, lock_radius, 0.0, TAU, 32, color, 3.0, true)
	draw_arc(center, lock_radius * 0.6, 0.0, TAU, 24, color, 2.0, true)
