extends PlayerGroundState

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		next_state.emit("Jump")
		return
	elif event.is_action_pressed("attack"):
		if player.deathfang_hitbox.can_deathfang():
			next_state.emit("Deathfang")
			return
		next_state.emit("Charging")
	elif event.is_action_released("dodge"):
		next_state.emit("Walk")
	elif event.is_action_pressed("switch_weapons"):
		if player.weapon_switch_cd.is_stopped():
			player.switch_weapons()
	elif event.is_action_pressed("special"):
		player.try_trigger_special()

func update(_delta: float) -> void:
	if player.input_dir == Vector3.ZERO:
		next_state.emit("Idle")
	elif player.velocity.y < 0:
		next_state.emit("Falling")

func physics_update(delta: float) -> void:
	if player.input_dir == Vector3.ZERO:
		return
	
	var target_velocity := player.input_dir * player.max_speed_run
	apply_ground_movement(target_velocity, delta)
	
	player.face_velocity_direction(delta)

func enter(_previous_state: State, _data := {}) -> void:
	animate_ground("Run")
	pass

func exit() -> void:
	pass
