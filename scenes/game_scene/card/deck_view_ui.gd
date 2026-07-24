class_name DeckViewUI
extends Control

@export var card_ui_scene : PackedScene

@onready var grid : GridContainer = %CardGrid
@onready var title_label : Label = %TitleLabel
@onready var dim : ColorRect = %Dim
@onready var close_button : Button = %CloseButton

func _ready() -> void:
	dim.gui_input.connect(_on_dim_gui_input)
	close_button.pressed.connect(_on_close_pressed)

func show_cards(cards : Array[CardResource]) -> void:
	for child in grid.get_children():
		child.queue_free()
	var sorted_cards := cards.duplicate()
	sorted_cards.sort_custom(_sort_cards)
	for card in sorted_cards:
		var ui : CardUI = card_ui_scene.instantiate()
		grid.add_child(ui)
		ui.preview_mode = true
		ui.setup(card)
	title_label.text = "Deck (%d)" % cards.size()
	show()

func _sort_cards(a : CardResource, b : CardResource) -> bool:
	if a.type != b.type:
		return a.type < b.type
	return a.card_name < b.card_name

func _on_dim_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_close_pressed()
	elif event is InputEventScreenTouch and event.pressed:
		_on_close_pressed()

func _on_close_pressed() -> void:
	hide()
