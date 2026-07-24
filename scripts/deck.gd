class_name Deck
extends RefCounted

signal deck_changed

var _draw_piles : Dictionary = {
	CardResource.CardType.UNIT: [],
	CardResource.CardType.ITEM: [],
}
var _discard_piles : Dictionary = {
	CardResource.CardType.UNIT: [],
	CardResource.CardType.ITEM: [],
}
var _active_type : int = CardResource.CardType.UNIT

func _init(starting_cards : Array[CardResource] = []) -> void:
	for card in starting_cards:
		_draw_piles[card.type].append(card)
	for type in _draw_piles.keys():
		_draw_piles[type].shuffle()

func set_active_type(type : int) -> void:
	if type == _active_type:
		return
	_active_type = type
	_draw_piles[_active_type].shuffle()
	deck_changed.emit()

func draw_card() -> CardResource:
	var pile : Array = _draw_piles[_active_type]
	if pile.is_empty():
		return null
	var card : CardResource = pile.pop_back()
	deck_changed.emit()
	return card

func reshuffle_if_hand_empty(type : int) -> void:
	if _draw_piles[type].is_empty():
		_reshuffle_discard_into_draw(type)

func discard(card : CardResource) -> void:
	if card == null:
		return
	_discard_piles[card.type].append(card)
	deck_changed.emit()

func return_card_to_draw(card : CardResource) -> void:
	if card == null:
		return
	var discard : Array = _discard_piles[card.type]
	var idx := discard.find(card)
	if idx == -1:
		return
	discard.remove_at(idx)
	var pile : Array = _draw_piles[card.type]
	pile.insert(randi_range(0, pile.size()), card)
	deck_changed.emit()

func _reshuffle_discard_into_draw(type : int) -> void:
	var discard : Array = _discard_piles[type]
	if discard.is_empty():
		return
	_draw_piles[type] = discard.duplicate()
	_discard_piles[type].clear()
	_draw_piles[type].shuffle()
	deck_changed.emit()

func get_all_cards() -> Array[CardResource]:
	var result : Array[CardResource] = []
	for type in _draw_piles.keys():
		result.append_array(_draw_piles[type])
	for type in _discard_piles.keys():
		result.append_array(_discard_piles[type])
	return result

func draw_count() -> int:
	return _draw_piles[_active_type].size()

func discard_count() -> int:
	return _discard_piles[_active_type].size()

func active_type() -> int:
	return _active_type
