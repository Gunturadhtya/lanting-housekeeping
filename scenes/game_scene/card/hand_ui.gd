class_name HandUI
extends HBoxContainer

signal card_play_requested(card : CardResource, drop_global_position : Vector2, card_ui : CardUI)

@export var card_ui_scene : PackedScene
@export var hand_size : int = 4

var deck : Deck
var drag_layer : Node = null
var _card_uis : Array[CardUI] = []

func setup(new_deck : Deck, new_drag_layer : Node = null) -> void:
	deck = new_deck
	drag_layer = new_drag_layer
	refill_hand()

func refill_hand() -> void:
	while _card_uis.size() < hand_size:
		if deck.draw_count() == 0 and _card_uis.is_empty() and deck.active_type() == CardResource.CardType.ITEM:
			deck.reshuffle_if_hand_empty(deck.active_type())
		var card : CardResource = deck.draw_card()
		if card == null:
			break
		_add_card_ui(card)

func _add_card_ui(card : CardResource) -> void:
	var ui : CardUI = card_ui_scene.instantiate()
	add_child(ui)
	ui.setup(card)
	ui.drag_layer = drag_layer
	ui.drag_ended.connect(_on_card_drag_ended)
	_card_uis.append(ui)

func _on_card_drag_ended(card_ui : CardUI, drop_global_position : Vector2) -> void:
	card_play_requested.emit(card_ui.card, drop_global_position, card_ui)

func confirm_play(card_ui : CardUI) -> void:
	_card_uis.erase(card_ui)
	deck.discard(card_ui.card)
	card_ui.queue_free()
	refill_hand()

func cancel_play(card_ui : CardUI) -> void:
	card_ui.return_to_hand()

func set_playable_type(type : int) -> void:
	for ui in _card_uis:
		ui.set_playable(ui.card.type == type)

func get_cards_in_hand() -> Array[CardResource]:
	var result : Array[CardResource] = []
	for ui in _card_uis:
		result.append(ui.card)
	return result
