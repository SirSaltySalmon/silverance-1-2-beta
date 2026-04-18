class_name PlayerAirState extends PlayerState

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func enter(_previous_state: State, _data := {}) -> void:
	if not player.has_multiplier("Air", "res"):
		player.add_multiplier("Air", "res", -1.0)

func exit() -> void:
	if player.has_multiplier("Air", "res"):
		player.remove_multiplier("Air", "res")

func apply_freefall_movement(target_velocity: Vector3, delta: float):
	apply_movement(target_velocity, delta, player.air_accel, player.air_turn_speed)

func apply_float_movement(target_velocity: Vector3, delta: float):
	apply_movement(target_velocity, delta, player.accel, player.turn_speed)

func animate_air(state: String):
	player.anim_tree["parameters/AirStates/state/transition_request"] = state
