extends Control

@export var event_pool : Array[EventResource] = []

@onready var title_label : Label = %TitleLabel
@onready var description_label : Label = %DescriptionLabel
@onready var art_rect : TextureRect = %ArtRect
@onready var options_row : VBoxContainer = %OptionsRow
@onready var result_label : Label = %ResultLabel
@onready var continue_button : Button = %ContinueButton

var _event : EventResource
var _resolved : bool = false

func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	continue_button.visible = false
	result_label.text = ""
	_event = _pick_event()
	_display_event()

## Setup

func _pick_event() -> EventResource:
	if event_pool.is_empty():
		return null
	var total : float = 0.0
	for event in event_pool:
		total += maxf(event.weight, 0.0)
	if total <= 0.0:
		return event_pool[randi() % event_pool.size()]

	var roll : float = randf() * total
	var accum : float = 0.0
	for event in event_pool:
		accum += maxf(event.weight, 0.0)
		if roll <= accum:
			return event
	return event_pool.back()

func _display_event() -> void:
	if _event == null:
		title_label.text = "Nothing Here"
		description_label.text = "The area is quiet. There's nothing left to find."
		art_rect.visible = false
		continue_button.visible = true
		return

	title_label.text = _event.event_name
	description_label.text = _event.description
	art_rect.visible = _event.texture != null
	art_rect.texture = _event.texture

	for child in options_row.get_children():
		child.queue_free()
	for i in range(_event.options.size()):
		var option : EventOptionResource = _event.options[i]
		var button := Button.new()
		button.text = _option_label(option)
		button.disabled = option.scrap_cost > RunManager.get_scrap()
		button.pressed.connect(_on_option_pressed.bind(i))
		options_row.add_child(button)

func _option_label(option : EventOptionResource) -> String:
	if option.scrap_cost > 0:
		return "%s (-%d Scrap)" % [option.option_text, option.scrap_cost]
	return option.option_text

## Resolution 

func _on_option_pressed(index : int) -> void:
	if _resolved or _event == null:
		return
	var option : EventOptionResource = _event.options[index]
	if option.scrap_cost > 0 and not RunManager.spend_scrap(option.scrap_cost):
		return
	_resolved = true

	if randf() <= option.success_chance:
		_apply_outcome(option.success_scrap_delta, option.success_hp_delta, option.success_card_reward_pool, option.success_removes_random_card)
		result_label.text = option.success_text
	else:
		_apply_outcome(option.failure_scrap_delta, option.failure_hp_delta, [], option.failure_removes_random_card)
		result_label.text = option.failure_text

	for child in options_row.get_children():
		child.queue_free()
	continue_button.visible = true

func _apply_outcome(scrap_delta : int, hp_delta : int, card_pool : Array[CardResource], removes_random_card : bool) -> void:
	if scrap_delta > 0:
		RunManager.add_scrap(scrap_delta)
	elif scrap_delta < 0:
		RunManager.spend_scrap(mini(-scrap_delta, RunManager.get_scrap()))

	if hp_delta > 0:
		RunManager.heal(hp_delta)
	elif hp_delta < 0:
		RunManager.apply_damage(-hp_delta)

	if not card_pool.is_empty():
		var available := RunManager.filter_ownable_cards(card_pool)
		if not available.is_empty():
			var card : CardResource = available[randi() % available.size()]
			RunManager.add_card(card)

	if removes_random_card:
		var deck := RunManager.get_deck()
		if not deck.is_empty():
			var card : CardResource = deck[randi() % deck.size()]
			RunManager.remove_card(card)

func _on_continue_pressed() -> void:
	CombatSceneTransitions.go_to_map()
