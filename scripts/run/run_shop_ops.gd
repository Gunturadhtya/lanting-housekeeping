class_name RunShopOps
extends RefCounted

static func remove_card(state : RunManager, card : CardResource) -> bool:
	var idx := state.deck.find(card)
	if idx == -1:
		return false
	state.deck.remove_at(idx)
	state.card_removals += 1
	return true
