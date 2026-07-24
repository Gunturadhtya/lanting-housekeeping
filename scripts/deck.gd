class_name Deck
extends RefCounted

signal deck_changed

var draw_pile : Array[CardResource] = []
var discard_pile : Array[CardResource] = []

func _init(starting_cards : Array[CardResource] = []) -> void:
	draw_pile = starting_cards.duplicate()
	draw_pile.shuffle()

func draw_card() -> CardResource:
	if draw_pile.is_empty():
		_reshuffle_discard_into_draw()
	if draw_pile.is_empty():
		return null
	var card : CardResource = draw_pile.pop_back()
	deck_changed.emit()
	return card

func discard(card : CardResource) -> void:
	if card == null:
		return
	discard_pile.append(card)
	deck_changed.emit()

func _reshuffle_discard_into_draw() -> void:
	if discard_pile.is_empty():
		return
	draw_pile = discard_pile.duplicate()
	discard_pile.clear()
	draw_pile.shuffle()
	deck_changed.emit()

func draw_count() -> int:
	return draw_pile.size()

func discard_count() -> int:
	return discard_pile.size()
