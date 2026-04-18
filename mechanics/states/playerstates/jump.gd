extends PlayerAirState

var last_state_is_run := false

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		next_state.emit("Plunging")

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	player.face_target_if_possible(delta)
	var max_speed := player.max_speed_run if last_state_is_run else player.max_speed_walk
	var target_velocity := player.input_dir * max_speed
	apply_freefall_movement(target_velocity, delta)
	
	if player.is_on_floor():
		next_state.emit("Idle")
	elif player.velocity.y <= 0.0:
		next_state.emit("Falling")

func enter(previous_state: State, data := {}) -> void:
	if previous_state.name == "Run":
		last_state_is_run = true
	else:
		last_state_is_run = false
	super(previous_state, data)
	player.velocity.y += player.jump_impulse
	player.anim_tree["parameters/AirStates/JumpOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
