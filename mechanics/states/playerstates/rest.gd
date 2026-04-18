extends PlayerGroundState

func handle_input(event: InputEvent) -> void:
	pass

func update(delta: float) -> void:
	if player.input_dir_2d != Vector2.ZERO:
		next_state.emit("StandingUp")

func physics_update(delta: float) -> void:
	pass

func enter(previous_state: State, _data := {}) -> void:
	animate_ground("Rest")

func exit() -> void:
	pass
