class_name StatsBarComponent extends ProgressBar

@export var parent: Character

func _ready():
	value = max_value

func generic_damage(damage: int) -> bool:
	## Return true if depleted
	value -= damage
	var depleted = value <= 0
	_on_damaged()
	if depleted:
		return true
	return false

func deplete() -> void:
	_on_damaged()
	value -= value

func restore():
	value = max_value

func heal():
	value += (max_value/2)

func heal_deathfang():
	value += (max_value/5)

func _on_damaged():
	pass

func update_maxmin_values(max_v: int = max_value, min_v: int = min_value) -> void:
	max_value = max_v
	min_value = min_v
