extends Control

## Workshop (Bengkel) rest site.
## The player may either repair the Lanting House (heal HP) or upgrade one
## card in their deck - but only ONE of those actions per visit. Once an
## action is taken both options lock and the player must leave.

const REPAIR_HEAL_RATIO : float = 0.3

@onready var hp_label : Label = %HpLabel
@onready var status_label : Label = %StatusLabel
@onready var repair_button : Button = %RepairButton
@onready var upgrade_button : Button = %UpgradeButton
@onready var leave_button : Button = %LeaveButton
@onready var upgrade_view : WorkshopUpgradeView = %WorkshopUpgradeView

var _used_workshop : bool = false

func _ready() -> void:
	repair_button.pressed.connect(_on_repair_pressed)
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	leave_button.pressed.connect(_on_leave_pressed)
	upgrade_view.card_chosen.connect(_on_card_chosen)

	_update_hp_label()
	_refresh_buttons()

func _upgradeable_cards() -> Array[CardResource]:
	var result : Array[CardResource] = []
	for card in RunManager.get_deck():
		if not card.upgraded:
			result.append(card)
	return result

func _repair_heal_amount() -> int:
	return maxi(1, int(round(RunManager.get_max_hp() * REPAIR_HEAL_RATIO)))

func _refresh_buttons() -> void:
	var is_full_hp := RunManager.get_hp() >= RunManager.get_max_hp()
	repair_button.disabled = _used_workshop or is_full_hp
	repair_button.text = "Repair Lanting House (Full HP)" if is_full_hp else "Repair Lanting House — Heal %d" % _repair_heal_amount()

	upgrade_button.disabled = _used_workshop or _upgradeable_cards().is_empty()

## ----- Repair -----

func _on_repair_pressed() -> void:
	if _used_workshop:
		return
	var amount := _repair_heal_amount()
	RunManager.heal(amount)
	_used_workshop = true
	_update_hp_label()
	_refresh_buttons()
	status_label.text = "Repaired the Lanting House for %d HP." % amount

## ----- Upgrade -----

func _on_upgrade_pressed() -> void:
	if _used_workshop:
		return
	upgrade_view.show_cards(_upgradeable_cards())

func _on_card_chosen(card : CardResource) -> void:
	if _used_workshop:
		upgrade_view.hide()
		return
	var upgraded_card := RunManager.upgrade_card(card)
	if upgraded_card == null:
		upgrade_view.hide()
		return
	_used_workshop = true
	upgrade_view.hide()
	_refresh_buttons()
	status_label.text = "Upgraded %s." % upgraded_card.card_name

## ----- Shared -----

func _update_hp_label() -> void:
	hp_label.text = "HP: %d/%d" % [RunManager.get_hp(), RunManager.get_max_hp()]

func _on_leave_pressed() -> void:
	CombatSceneTransitions.go_to_map()
