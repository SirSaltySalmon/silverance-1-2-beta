extends PlayerAirState

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		next_state.emit("Plunging")
	if event.is_action_released("jump"):
		next_state.emit("Falling")

func update(_delta: float) -> void:
	if player.stamina._is_empty():
		next_state.emit("Falling")

func physics_update(delta: float) -> void:
	player.face_target_if_possible(delta)
	
	if player.input_dir == Vector3.ZERO:
		return
	var target_velocity := player.input_dir * player.max_speed_run
	apply_float_movement(target_velocity, delta)

func enter(_previous_state: State, _data := {}) -> void:
	animate_air("Float")
	player._negate_gravity()

func exit() -> void:
	player._apply_gravity()
