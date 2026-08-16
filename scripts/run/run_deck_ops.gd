class_name RunDeckOps
extends RefCounted

static func set_deck(state : RunManager, cards : Array[CardResource]) -> void:
	state.deck = cards.duplicate()

static func can_add_card(state : RunManager, card : CardResource) -> bool:
	if card == null:
		return false
	if card.type != CardResource.CardType.UNIT:
		return true
	return not owns_unit_card(state, card.card_id)

static func owns_unit_card(state : RunManager, card_id : String) -> bool:
	if card_id == "":
		return false
	for card : CardResource in state.deck:
		if card.type == CardResource.CardType.UNIT and card.card_id == card_id:
			return true
	return false

static func add_card(state : RunManager, card : CardResource) -> bool:
	if not can_add_card(state, card):
		return false
	state.deck.append(card)
	return true

static func dedupe_unit_cards(cards : Array[CardResource]) -> Array[CardResource]:
	var result : Array[CardResource] = []
	var seen_unit_cards : Dictionary = {}
	for card in cards:
		if card == null:
			continue
		if card.type == CardResource.CardType.UNIT:
			if card.card_id != "" and seen_unit_cards.has(card.card_id):
				continue
			seen_unit_cards[card.card_id] = true
		result.append(card)
	return result
