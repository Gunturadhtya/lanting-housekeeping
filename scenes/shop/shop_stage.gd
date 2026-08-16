extends Control

const OFFER_COUNT : int = 4
const BASE_REMOVE_COST : int = 75
const REMOVE_COST_STEP : int = 25

@export var shop_card_pool : Array[CardResource] = []
@export var card_ui_scene : PackedScene

@onready var scrap_label : Label = %ScrapLabel
@onready var offer_row : HBoxContainer = %OfferRow
@onready var remove_button : Button = %RemoveButton
@onready var leave_button : Button = %LeaveButton
@onready var remove_view : ShopRemoveView = %ShopRemoveView

var _offers : Array[CardResource] = []
var _buy_buttons : Dictionary = {} 
var _card_uis : Dictionary = {} 

func _ready() -> void:
	remove_button.pressed.connect(_on_remove_button_pressed)
	leave_button.pressed.connect(_on_leave_pressed)
	remove_view.card_chosen.connect(_on_remove_card_chosen)
	remove_view.closed.connect(_on_remove_view_closed)

	_generate_offers()
	_update_scrap_label()
	_update_remove_button()

## Buying

func _generate_offers() -> void:
	for child in offer_row.get_children():
		child.queue_free()
	_buy_buttons.clear()
	_card_uis.clear()

	var pool : Array[CardResource] = RunManager.filter_ownable_cards(shop_card_pool)
	pool.shuffle()
	_offers = pool.slice(0, mini(OFFER_COUNT, pool.size()))

	for i in range(_offers.size()):
		_spawn_offer(i, _offers[i])

	_refresh_offer_affordability()

func _spawn_offer(index : int, card : CardResource) -> void:
	var wrapper := VBoxContainer.new()
	wrapper.custom_minimum_size = Vector2(120, 210)
	wrapper.add_theme_constant_override("separation", 6)
	offer_row.add_child(wrapper)

	var card_holder := Control.new()
	card_holder.custom_minimum_size = Vector2(110, 150)
	wrapper.add_child(card_holder)

	var ui : CardUI = card_ui_scene.instantiate()
	card_holder.add_child(ui)
	ui.preview_mode = true
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.setup(card)
	_card_uis[index] = ui

	var buy_button := Button.new()
	buy_button.text = "Buy — %d" % card.shop_price
	buy_button.pressed.connect(_on_buy_pressed.bind(index))
	wrapper.add_child(buy_button)
	_buy_buttons[index] = buy_button

func _on_buy_pressed(index : int) -> void:
	if not _buy_buttons.has(index):
		return
	var button : Button = _buy_buttons[index]
	if button.disabled:
		return
	var card : CardResource = _offers[index]
	if not RunManager.can_add_card(card):
		return
	if not RunManager.spend_scrap(card.shop_price):
		return

	RunManager.add_card(card)

	button.text = "Sold"
	button.disabled = true
	if _card_uis.has(index):
		_card_uis[index].modulate = Color(1, 1, 1, 0.5)

	_update_scrap_label()
	_refresh_offer_affordability()

func _refresh_offer_affordability() -> void:
	var scrap := RunManager.get_scrap()
	for index in _buy_buttons.keys():
		var button : Button = _buy_buttons[index]
		if button.text == "Sold":
			continue
		var card : CardResource = _offers[index]
		button.disabled = scrap < card.shop_price or not RunManager.can_add_card(card)

## Removing

func _current_remove_cost() -> int:
	return BASE_REMOVE_COST + RunManager.get_card_removals() * REMOVE_COST_STEP

func _update_remove_button() -> void:
	var cost := _current_remove_cost()
	remove_button.text = "Remove a Card — %d" % cost
	remove_button.disabled = RunManager.get_deck().is_empty() or RunManager.get_scrap() < cost

func _on_remove_button_pressed() -> void:
	remove_view.show_cards(RunManager.get_deck(), _current_remove_cost())

func _on_remove_card_chosen(card : CardResource) -> void:
	var cost := _current_remove_cost()
	if not RunManager.spend_scrap(cost):
		return
	RunManager.remove_card(card)
	remove_view.hide()
	_update_scrap_label()
	_update_remove_button()
	_refresh_offer_affordability()

func _on_remove_view_closed() -> void:
	pass

## Shared

func _update_scrap_label() -> void:
	scrap_label.text = "Scrap: %d" % RunManager.get_scrap()

func _on_leave_pressed() -> void:
	CombatSceneTransitions.go_to_map()
