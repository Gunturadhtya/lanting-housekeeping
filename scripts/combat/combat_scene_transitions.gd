class_name CombatSceneTransitions
extends RefCounted

static func go_to_map() -> void:
	SceneLoader.load_scene("res://scenes/map/map_view.tscn")

static func go_to_main_menu() -> void:
	RunManager.clear_run()
	SceneLoader.load_scene("res://scenes/menus/main_menu/main_menu.tscn")
