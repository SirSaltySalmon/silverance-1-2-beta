extends PlayerGroundState

func _ready():
	pass # Because player is set upon trigger

func enter(_previous_state: State, _data := {}) -> void:
	player.attacking = true
	player.attack_type = "DODGE"
	player.poise.pause_regen()
	player.hit_counter = 0
	player.reset_weapon()
	
	animate_insta("Special")
	_special_animation("Wild Strikes")
	apply_attack_impulse()

func physics_update(delta: float) -> void:
	player.face_target_if_possible(delta, true)
	
	if player.input_dir:
		var target_velocity := player.input_dir * player.max_speed_run
		if player.block.blocking:
			target_velocity /= 2.0
		apply_ground_movement(target_velocity, delta)
	else:
		apply_drag(0, delta)

func exit() -> void:
	player.attacking = false
	player.poise.resume_regen()
	player.reset_weapon()
	
	player.anim_tree["parameters/GroundStates/insta_trans/transition_request"] = "Ground"
	
	reparent(player.equipped_weapon_nodes[0])

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
