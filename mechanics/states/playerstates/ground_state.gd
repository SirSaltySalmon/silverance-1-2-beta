class_name PlayerGroundState extends PlayerState

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func enter(_previous_state: State, _data := {}) -> void:
	pass

func exit() -> void:
	pass

func animate_ground(state: String) -> void:
	# Dodge blending is set in the Dodge state's code instead of here
	player.anim_tree["parameters/GroundStates/states/transition_request"] = state

func animate_insta(state: String) -> void:
	player.anim_tree["parameters/GroundStates/insta_trans/transition_request"] = state

func _attack_animation(animation_code: String):
	var all_moveset_path = "parameters/GroundStates/AttackMovesets/playback"
	var all_moveset: AnimationNodeStateMachinePlayback = player.anim_tree[all_moveset_path]
	assert(all_moveset != null, "Attack movesets not found")
	all_moveset.travel(player.weapon_type)
	
	var moveset_path = "parameters/GroundStates/AttackMovesets/" + player.weapon_type + "/playback"
	var moveset: AnimationNodeStateMachinePlayback = player.anim_tree[moveset_path]
	assert(moveset != null, "Attack moveset is not found for weapon type " + player.weapon_type)
	moveset.travel(animation_code)

func _special_animation(animation_code: String):
	var all_specials_path = "parameters/GroundStates/Specials/playback"
	var all_specials: AnimationNodeStateMachinePlayback = player.anim_tree[all_specials_path]
	assert(all_specials != null, "Special movesets not found")
	all_specials.travel(animation_code)

func apply_ground_movement(target_velocity: Vector3, delta: float):
	apply_movement(target_velocity, delta, player.accel, player.turn_speed)

func apply_drag(target_speed: float, delta: float):
	if player.velocity.length() > target_speed:
		var horizontal_velocity = Vector2(player.velocity.x, player.velocity.z)
		var current_speed = horizontal_velocity.length()
		if current_speed == 0.0:
			return ## Prevents dividing by zero
		var new_speed = max(current_speed - player.accel * delta, target_speed)
		var speed_ratio = new_speed / current_speed
		player.velocity.x *= speed_ratio
		player.velocity.z *= speed_ratio
