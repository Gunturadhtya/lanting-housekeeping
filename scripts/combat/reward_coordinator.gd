class_name RewardCoordinator
extends RefCounted

signal victory_confirmed(next_level_path : String)

var _reward_phase : RewardPhase
var _deck : Deck
var _next_level_path : String

func _init(reward_phase : RewardPhase, deck : Deck, next_level_path : String) -> void:
	_reward_phase = reward_phase
	_deck = deck
	_next_level_path = next_level_path

func show_victory_reward(reward_card_pool : Array[CardResource]) -> void:
	if not _reward_phase.closed.is_connected(_on_reward_closed):
		_reward_phase.closed.connect(_on_reward_closed)
	if not _reward_phase.card_chosen.is_connected(_on_card_chosen):
		_reward_phase.card_chosen.connect(_on_card_chosen)
	_reward_phase.show_reward(reward_card_pool)

func _on_card_chosen(card : CardResource) -> void:
	_deck.add_card(card)

func _on_reward_closed() -> void:
	RunManager.set_deck(_deck.get_all_cards())
	victory_confirmed.emit(_next_level_path)
