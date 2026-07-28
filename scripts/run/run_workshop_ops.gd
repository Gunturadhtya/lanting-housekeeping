class_name RunWorkshopOps
extends RefCounted

static func upgrade_card(state : RunManager, card : CardResource) -> CardResource:
	if card == null or card.upgraded:
		return null
	var idx := state.deck.find(card)
	if idx == -1:
		return null
	var upgraded_card := card.create_upgraded()
	state.deck[idx] = upgraded_card
	return upgraded_card
