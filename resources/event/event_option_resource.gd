class_name EventOptionResource
extends Resource

@export var option_text : String = "Option"
@export var scrap_cost : int = 0

@export_group("Success")
@export_range(0.0, 1.0) var success_chance : float = 1.0
@export_multiline var success_text : String = ""
@export var success_scrap_delta : int = 0
@export var success_hp_delta : int = 0
@export var success_card_reward_pool : Array[CardResource] = []
@export var success_removes_random_card : bool = false

@export_group("Failure")
@export_multiline var failure_text : String = ""
@export var failure_scrap_delta : int = 0
@export var failure_hp_delta : int = 0
@export var failure_removes_random_card : bool = false
