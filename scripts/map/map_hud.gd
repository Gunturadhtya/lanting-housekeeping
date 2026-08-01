class_name MapHud
extends RefCounted

var _scrap_label : Label
var _deck_button : Button

func _init(scrap_label : Label, deck_button : Button) -> void:
	_scrap_label = scrap_label
	_deck_button = deck_button

func show_scrap(amount : int) -> void:
	_scrap_label.text = "Scrap: %d" % amount

func show_deck(count : int) -> void:
	_deck_button.text = "Deck: %d" % count
