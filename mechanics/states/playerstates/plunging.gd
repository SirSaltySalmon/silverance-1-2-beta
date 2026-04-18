extends PlayerAirState

func handle_input(_event: InputEvent) -> void:
	pass

func update(delta: float) -> void:
	if player.is_on_floor():
		for i in player.get_slide_collision_count():
			var collision = player.get_slide_collision(i)
			var collider = collision.get_collider()
			if collider is Character:
				## Extremely unlikely that plunging lands on top of a character, in that case gets out
				print("Is on top of another char, will accelerate to fall out")
				print(collider.name)
				var direction = (player._calculate_3d_dir(Vector2(0,1),player._get_rig_rotation().y))
				player.velocity -= direction * delta
				return
		player.attack_type = "PLUNGE"
		next_state.emit("Attack")

func physics_update(delta: float) -> void:
	player.face_target_if_possible(delta)
	
	if player.input_dir == Vector3.ZERO:
		return
	var target_velocity := player.input_dir * player.max_speed_walk
	apply_freefall_movement(target_velocity, delta)

func enter(previous_state: State, data := {}) -> void:
	super(previous_state, data)
	player.set_collision_mask_value(2, false)
	player.set_collision_mask_value(3, false)
	animate_air("Plunging")

func exit():
	super()
	player.set_collision_mask_value(2, true)
	player.set_collision_mask_value(3, true)
