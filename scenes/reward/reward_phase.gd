class_name RewardPhase
extends Control

signal card_chosen(card : CardResource)
signal scrap_chosen(amount : int)
signal closed

@export var card_ui_scene : PackedScene
@export var min_scrap_reward : int = 15
@export var max_scrap_reward : int = 30

@onready var card_row : HBoxContainer = %CardRow
@onready var scrap_button : Button = %ScrapButton
@onready var title_label : Label = %TitleLabel
@onready var dim : ColorRect = %Dim

var _resolved : bool = false
var _scrap_amount : int = 0

func _ready() -> void:
	scrap_button.pressed.connect(_on_scrap_pressed)
	hide()

func show_reward(card_pool : Array[CardResource], scrap_amount : int = -1) -> void:
	_resolved = false
	_scrap_amount = scrap_amount if scrap_amount >= 0 else randi_range(min_scrap_reward, max_scrap_reward)

	for child in card_row.get_children():
		child.queue_free()
	for card in _pick_random_cards(card_pool, 3):
		var wrapper := Control.new()
		wrapper.custom_minimum_size = Vector2(110, 150)
		card_row.add_child(wrapper)          

		var ui : CardUI = card_ui_scene.instantiate()
		wrapper.add_child(ui)                
		ui.preview_mode = true
		ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		ui.setup(card)                       

		var overlay := Button.new()
		overlay.flat = true
		overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		overlay.focus_mode = Control.FOCUS_NONE
		overlay.pressed.connect(_choose_card.bind(card))
		wrapper.add_child(overlay)

	scrap_button.text = "Take %d Scrap" % _scrap_amount
	title_label.text = "Victory! Choose a Reward"
	show()

func _pick_random_cards(pool : Array[CardResource], count : int) -> Array[CardResource]:
	var options : Array[CardResource] = pool.duplicate()
	options.shuffle()
	var result : Array[CardResource] = []
	for card in options:
		if result.size() >= count:
			break
		result.append(card)
	return result

func _choose_card(card : CardResource) -> void:
	if _resolved:
		return
	_resolved = true
	card_chosen.emit(card) 
	_close()

func _on_scrap_pressed() -> void:
	if _resolved:
		return
	_resolved = true
	RunManager.add_scrap(_scrap_amount)
	scrap_chosen.emit(_scrap_amount)
	_close()

func _close() -> void:
	hide()
	closed.emit()
