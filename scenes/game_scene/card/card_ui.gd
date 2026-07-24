class_name CardUI
extends PanelContainer

signal drag_ended(card_ui : CardUI, drop_global_position : Vector2)

@export var card : CardResource
@export var stuck_drag_timeout : float = 4.0
@export var preview_mode : bool = false

var drag_layer : Node = null

@onready var name_label : Label = %NameLabel
@onready var type_label : Label = %TypeLabel
@onready var stat_label : Label = %StatLabel
@onready var art_rect : TextureRect = %ArtRect

var _dragging : bool = false
var _drag_offset : Vector2 = Vector2.ZERO
var _original_parent : Node = null
var _original_index : int = 0
var _playable : bool = true
var _pointer_index : int = -1
var _stuck_timer : Timer

func _ready() -> void:
	_stuck_timer = Timer.new()
	_stuck_timer.one_shot = true
	_stuck_timer.timeout.connect(_on_stuck_timeout)
	add_child(_stuck_timer)
	set_process_input(false)
	if preview_mode:
		mouse_filter = Control.MOUSE_FILTER_IGNORE

func setup(new_card : CardResource) -> void:
	card = new_card
	if name_label:
		name_label.text = card.card_name
	if type_label:
		type_label.text = "UNIT" if card.type == CardResource.CardType.UNIT else "ITEM"
	if art_rect and card.texture:
		art_rect.texture = card.texture
	if stat_label:
		if card.type == CardResource.CardType.UNIT:
			stat_label.text = "HP %d  DMG %d" % [card.unit_max_health, card.unit_attack_damage]
		else:
			stat_label.text = "DMG %d  AoE %d" % [card.item_damage, int(card.item_radius)]

func set_playable(playable : bool) -> void:
	_playable = playable
	modulate = Color(1, 1, 1, 1) if playable else Color(1, 1, 1, 0.35)
	mouse_filter = Control.MOUSE_FILTER_STOP if playable else Control.MOUSE_FILTER_IGNORE
	if not playable and _dragging:
		_finish_drag(global_position + _drag_offset)

func _gui_input(event : InputEvent) -> void:
	if preview_mode:
		return
	if not _playable or _dragging:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_begin_drag(-1, event.global_position)
		get_viewport().set_input_as_handled()
	elif event is InputEventScreenTouch and event.pressed:
		_begin_drag(event.index, event.position)
		get_viewport().set_input_as_handled()

func _begin_drag(pointer_index : int, global_pos : Vector2) -> void:
	_dragging = true
	_pointer_index = pointer_index
	_drag_offset = global_pos - global_position
	_original_parent = get_parent()
	_original_index = get_index()
	if drag_layer and _original_parent:
		_original_parent.remove_child(self)
		drag_layer.add_child(self)
	global_position = global_pos - _drag_offset
	z_index = 100
	set_process_input(true)
	_stuck_timer.start(stuck_drag_timeout)

func _input(event : InputEvent) -> void:
	if not _dragging:
		return
	if _pointer_index == -1:
		if event is InputEventMouseMotion:
			global_position = event.global_position - _drag_offset
			_stuck_timer.start(stuck_drag_timeout)
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_finish_drag(event.global_position)
			get_viewport().set_input_as_handled()
	else:
		if event is InputEventScreenDrag and event.index == _pointer_index:
			global_position = event.position - _drag_offset
			_stuck_timer.start(stuck_drag_timeout)
			get_viewport().set_input_as_handled()
		elif event is InputEventScreenTouch and event.index == _pointer_index and not event.pressed:
			_finish_drag(event.position)
			get_viewport().set_input_as_handled()

func _notification(what : int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and _dragging:
		_finish_drag(global_position + _drag_offset)

func _on_stuck_timeout() -> void:
	if _dragging:
		_finish_drag(global_position + _drag_offset)

func _finish_drag(drop_global_position : Vector2) -> void:
	_dragging = false
	_pointer_index = -1
	set_process_input(false)
	_stuck_timer.stop()
	z_index = 0
	drag_ended.emit(self, drop_global_position)

func return_to_hand() -> void:
	if _original_parent == null:
		return
	if get_parent() != _original_parent:
		get_parent().remove_child(self)
		_original_parent.add_child(self)
		_original_parent.move_child(self, clampi(_original_index, 0, _original_parent.get_child_count() - 1))
	z_index = 0
