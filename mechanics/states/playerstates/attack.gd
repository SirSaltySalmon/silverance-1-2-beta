extends PlayerGroundState

@export var combo_timeout: Timer
@export var combo_timeout_duration := 1.0

func _ready():
	super()
	combo_timeout.connect("timeout", _on_combo_timeout)

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	# Apply drag
	if player.attack_type in ["RUNNING", "PLUNGE"]:
		# Apply less drag to inherit more velocity if running attack
		delta = delta / 2.0
	apply_drag(0.0, delta)
	
	if player.attacking:
		return
	else:
		if player.target != null:
			player.face_target(delta)
		else:
			player.face_input_direction(delta)

func enter(_previous_state: State, _data := {}) -> void:
	if player.switch_buffer.should_run_action():
		if player.weapon_switch_cd.is_stopped():
			player.switch_weapons()
	
	player.poise.pause_regen()
	player.hit_counter = 0
	
	combo_timeout.stop()
	if "BASIC" in player.attack_type:
		player.combo_counter = (player.combo_counter + 1) % 3
	else:
		player.combo_counter = 0
	
	# Check required because user may be performing unarmed attacks
	if player.equipped_weapon_nodes:
		player.reset_weapon()
	
	animate_insta("Attacks")
	_attack_animation(player.attack_type)
	
	# handle velocity gained from performing an attack
	if player.attack_type in ["RUNNING", "PLUNGE"]:
		# Player velocity is inherited, rotated to correct direction, no need for attack impulse
		if player.attack_type == "PLUNGE":
			player.camera.shake_short()
	else:
		player.attack_launched.connect(apply_attack_impulse)
	player.anim_tree.animation_finished.connect(_on_animation_finished)

func apply_attack_impulse():
	var direction: Vector3
	if player.target:
		# if is locked on to a target, orient impulses towards enemy
		direction = (player._calculate_3d_dir(Vector2(0,1),player.get_rotation_to_target().y))
	else:
		# else, calculate direction of attack based on rig rotation
		direction = (player._calculate_3d_dir(Vector2(0,1),player._get_rig_rotation().y))
	player.velocity = Vector3.ZERO
	player.velocity.x = direction.x * player.attack_impulse
	player.velocity.z = direction.z * player.attack_impulse

func _on_animation_finished(anim_name: String):
	## Calculates next buffered actions immmediately
	if player.dodge_buffer.should_run_action():
		next_state.emit("Dodge")
		return
	if player.attack_buffer.should_run_action():
		
		## Buffered attack input, prioritize deathfang first
		if player.deathfang_hitbox.can_deathfang():
			next_state.emit("Deathfang")
			return
		
		player.attack_type = "BASIC_" + str(player.combo_counter)
		next_state.emit("Attack")
		return
	if Input.is_action_pressed("attack"):
		next_state.emit("Charging")
		return
	
	if player.is_on_floor():
		next_state.emit("Idle")
	else:
		next_state.emit("Falling")

func exit() -> void:
	player.attacking = false # Ensure correct flag when interrupted
	player.poise.resume_regen()
	
	# Disconnect any pending signals to prevent callbacks
	if player.attack_launched.is_connected(apply_attack_impulse):
		player.attack_launched.disconnect(apply_attack_impulse)
	if player.anim_tree.animation_finished.is_connected(_on_animation_finished):
		player.anim_tree.animation_finished.disconnect(_on_animation_finished)
	
	player.anim_tree["parameters/GroundStates/insta_trans/transition_request"] = "Ground"
	combo_timeout.start(combo_timeout_duration)
	if player.equipped_weapon_nodes:
		player.reset_weapon()

func _on_combo_timeout() -> void:
	player.combo_counter = 0
