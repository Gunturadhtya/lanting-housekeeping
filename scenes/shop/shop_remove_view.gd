class_name ShopRemoveView
extends Control

signal card_chosen(card : CardResource)
signal closed

@export var card_ui_scene : PackedScene

@onready var grid : GridContainer = %CardGrid
@onready var title_label : Label = %TitleLabel
@onready var dim : ColorRect = %Dim
@onready var close_button : Button = %CloseButton

func _ready() -> void:
	dim.gui_input.connect(_on_dim_gui_input)
	close_button.pressed.connect(_on_close_pressed)
	hide()

func show_cards(cards : Array[CardResource], cost : int) -> void:
	for child in grid.get_children():
		child.queue_free()

	var sorted_cards := cards.duplicate()
	sorted_cards.sort_custom(_sort_cards)
	for card in sorted_cards:
		var wrapper := Control.new()
		wrapper.custom_minimum_size = Vector2(110, 150)
		grid.add_child(wrapper)

		var ui : CardUI = card_ui_scene.instantiate()
		wrapper.add_child(ui)
		ui.preview_mode = true
		ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		ui.setup(card)

		var overlay := Button.new()
		overlay.flat = true
		overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		overlay.focus_mode = Control.FOCUS_NONE
		overlay.tooltip_text = "Remove for %d Scrap" % cost
		overlay.pressed.connect(_on_card_pressed.bind(card))
		wrapper.add_child(overlay)

	title_label.text = "Remove a Card — Cost %d Scrap" % cost
	show()

func _sort_cards(a : CardResource, b : CardResource) -> bool:
	if a.type != b.type:
		return a.type < b.type
	return a.card_name < b.card_name

func _on_card_pressed(card : CardResource) -> void:
	card_chosen.emit(card)

func _on_dim_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_close_pressed()
	elif event is InputEventScreenTouch and event.pressed:
		_on_close_pressed()

func _on_close_pressed() -> void:
	hide()
	closed.emit()
