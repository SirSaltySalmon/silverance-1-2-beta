extends NPCGroundState

func physics_update(delta: float) -> void:
	var direction: Vector3
	
	if npc.target_movement_direction:
		## Determins movement relative to direction rig is facing
		direction = npc._calculate_3d_dir(npc.target_movement_direction, npc._get_rig_rotation().y)
	elif npc.target_position:
		direction = npc._calculate_3d_dir(Vector2.DOWN, npc.get_rotation_to(npc.target_position).y)
	
	var target_velocity := direction * npc.max_speed_walk
	if npc.block.blocking:
		target_velocity /= 2.0
	apply_ground_movement(target_velocity, delta)
	
	if npc.target_movement_direction and npc.target:
		npc.face_target(delta)
	else:
		npc.face_direction(delta, npc.velocity)

func enter(_previous_state: State, _data := {}):
	super(_previous_state, _data)
	if npc.block:
		if npc.block.blocking:
			npc.animate_ground("BlockWalk")
			return
	npc.animate_ground("Walk")

func exit():
	super()
	npc.target_movement_direction = Vector2.ZERO
	npc.target_position = Vector3.ZERO

func apply_ground_movement(target_velocity: Vector3, delta: float):
	apply_movement(target_velocity, delta, npc.accel, npc.turn_speed)
	
