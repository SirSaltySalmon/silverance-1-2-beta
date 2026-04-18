extends PlayerGroundState

var register_dodge: bool = true

func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		next_state.emit("Jump")
	elif event.is_action_pressed("attack"):
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
	if player.input_dir != Vector3.ZERO:
		next_state.emit("Walk", {"register_dodge" = register_dodge})
	if player.velocity.y < 0:
		next_state.emit("Falling")
	
	if register_dodge and check_for_hold("dodge", delta):
		register_dodge = false

func physics_update(delta: float) -> void:
	# Apply drag. Multiplied by 2 to make stopping more responsive
	apply_drag(0.0, delta * 2)
	
	player.face_target_if_possible(delta, true)

func enter(previous_state: State, _data := {}) -> void:
	## Prevent dodge from being inputted if the user is holding the shift key while entering idle state
	## So far this can be triggered if:
	## 1. The user released wasd keys while running before they release the shift key, then release the shift key shortly after
	## 2. The user hold shift while falling, then release it on ground. Can transition into the walk state before the dodge (unchecked for now)
	## can be registered so data is passed onto the walk state to handle this as well.
	## But also take into account of buffer to see if the release was intentional
	if (previous_state.name in ["Run", "Attack", "Falling"] and not player.dodge_buffer.should_run_action()):
		register_dodge = false
	else:
		register_dodge = true
	
	if previous_state.name == "Falling":
		_animate_landing()
	if player.block.blocking:
		animate_ground("Block")
	elif player.input_dir_2d == Vector2.ZERO:
		animate_ground("Idle")
	
	if player.switch_buffer.should_run_action():
		if player.weapon_switch_cd.is_stopped():
			player.switch_weapons()

func block_animation_enable():
	animate_ground("Block")

func block_animation_disable():
	animate_ground("Idle")

func exit() -> void:
	pass

func _animate_landing() -> void:
	player.anim_tree["parameters/GroundStates/LandingOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
