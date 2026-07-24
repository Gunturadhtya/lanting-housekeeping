extends Control

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_apply_safe_area()


func _apply_safe_area() -> void:
	var screen_size := Vector2(DisplayServer.screen_get_size())
	var safe_area := DisplayServer.get_display_safe_area()
	var viewport_size := get_viewport().get_visible_rect().size
	
	var scale := viewport_size / screen_size

	var left := safe_area.position.x * scale.x
	var top := safe_area.position.y * scale.y
	var right := (screen_size.x - safe_area.end.x) * scale.x
	var bottom := (screen_size.y - safe_area.end.y) * scale.y

	offset_left = left
	offset_top = top
	offset_right = -right
	offset_bottom = -bottom
