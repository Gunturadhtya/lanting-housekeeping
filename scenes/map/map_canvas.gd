class_name MapCanvas
extends Control

var _lines : Array[Dictionary] = []

func set_lines(lines : Array[Dictionary]) -> void:
	_lines = lines
	queue_redraw()

func _draw() -> void:
	for line in _lines:
		draw_line(line["from"], line["to"], line["color"], line["width"], true)
