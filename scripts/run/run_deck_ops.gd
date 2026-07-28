class_name RunDeckOps
extends RefCounted

static func set_deck(state : RunManager, cards : Array[CardResource]) -> void:
	state.deck = cards.duplicate()

static func add_card(state : RunManager, card : CardResource) -> void:
	state.deck.append(card)
