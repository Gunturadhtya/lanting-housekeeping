class_name ScrapEconomy
extends RefCounted

signal scrap_changed(total : int)

var scrap : int = 0

func initialize() -> void:
	scrap = RunManager.get_scrap() if RunManager.has_active_run() else 0
	scrap_changed.emit(scrap)

func collect(amount : int) -> void:
	scrap += amount
	RunManager.add_scrap(amount)
	scrap_changed.emit(scrap)
