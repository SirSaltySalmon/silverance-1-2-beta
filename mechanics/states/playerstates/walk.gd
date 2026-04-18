extends PlayerGroundState

var register_dodge: bool = true

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
		if register_dodge:
			next_state.emit("Dodge")
		else:
			register_dodge = true
	elif event.is_action_pressed("switch_weapons"):
		if player.weapon_switch_cd.is_stopped():
			player.switch_weapons()
	elif event.is_action_pressed("special"):
		player.try_trigger_special()

func update(delta: float) -> void:
	if player.input_dir == Vector3.ZERO:
		next_state.emit("Idle")
	elif player.velocity.y < 0:
		next_state.emit("Falling")
	elif check_for_hold("dodge", delta):
		next_state.emit("Run")

func physics_update(delta: float) -> void:
	player.face_target_if_possible(delta)
	
	var target_velocity := player.input_dir * player.max_speed_walk
	if player.block.blocking:
		target_velocity /= 2.0
	apply_ground_movement(target_velocity, delta)

func enter(_previous_state: State, data := {}) -> void:
	reset_hold_counter()
	if player.block.blocking:
		animate_ground("BlockWalk")
	else:
		animate_ground("Walk")
	if data.has("register_dodge"):
		register_dodge = data["register_dodge"]
	else:
		register_dodge = true
	
	if player.switch_buffer.should_run_action():
		if player.weapon_switch_cd.is_stopped():
			player.switch_weapons()

func block_animation_enable():
	animate_ground("BlockWalk")

func block_animation_disable():
	animate_ground("Walk")

func exit() -> void:
	pass
