extends NPCGroundState

func physics_update(delta: float) -> void:
	apply_drag(0, delta)
	if npc.target:
		npc.face_target(delta)

func enter(previous_state: State, data := {}) -> void:
	npc.poise.pause_regen()
	npc.hit_counter = 0
	
	super(previous_state, data)
	npc.animate_insta("Attacks")
	
	_attack_animation()
	
	npc.attack_launched.connect(apply_attack_impulse)
	npc.anim_tree.animation_finished.connect(_on_animation_finished)

func exit() -> void:
	npc.attacking = false # Ensure correct flag when interrupted
	npc.poise.resume_regen()
	
	npc.animate_insta("Ground")
	super()
	if npc.is_connected("attack_launched", apply_attack_impulse):
		npc.disconnect("attack_launched", apply_attack_impulse)
	if npc.anim_tree.animation_finished.is_connected(_on_animation_finished):
		npc.anim_tree.animation_finished.disconnect(_on_animation_finished)

func _on_animation_finished(anim_name: String):
	next_state.emit("Idle")

func apply_attack_impulse():
	## Only orient direction via rig rotation to make enemy attacks visually predictable
	var direction:= (npc._calculate_3d_dir(Vector2(0,1),npc._get_rig_rotation().y))
	npc.velocity = Vector3.ZERO
	npc.velocity.x = direction.x * npc.attack_impulse
	npc.velocity.z = direction.z * npc.attack_impulse

func _attack_animation():
	## IF THE CHAR IS REPEATEDLY USING AN ATTACK, MUST ALLOW TRANSITION TO SELF
	var moveset_path = "parameters/GroundStates/ATTACKMOVESET/playback"
	var moveset: AnimationNodeStateMachinePlayback = npc.anim_tree[moveset_path]
	assert(moveset != null, "Attack moveset is not found for this character")
	moveset.travel(npc.attack_type)
