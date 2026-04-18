extends PlayerAirState

var last_state_is_run := false

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		next_state.emit("Plunging")

func update(_delta: float) -> void:
	if (Input.is_action_pressed("jump")
		and player._can_start_floating()):
		next_state.emit("Float")
	if player.is_on_floor():
		next_state.emit("Idle", {"hold_counter" = hold_counter})

func physics_update(delta: float) -> void:
	player.face_target_if_possible(delta)
	var max_speed := player.max_speed_run if last_state_is_run else player.max_speed_walk
	var target_velocity := player.input_dir * max_speed
	apply_freefall_movement(target_velocity, delta)

func enter(previous_state: State, data := {}) -> void:
	if previous_state.name == "Run":
		last_state_is_run = true
	else:
		last_state_is_run = false
	super(previous_state, data)
	animate_air("Falling")
	pass
