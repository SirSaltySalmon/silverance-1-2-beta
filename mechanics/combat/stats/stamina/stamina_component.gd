class_name StaminaComponent extends ProgressBar
var player: Player

func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "Stamina Component not Attached to a Player")

func _process(delta: float) -> void:
	if player.state_machine.state.name == "Float":
		value -= player.stamina_use_rate * delta
	else:
		value += player.stamina_refill_rate * delta

func _is_empty() -> bool:
	return get_value() == 0.0
