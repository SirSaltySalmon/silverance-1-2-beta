extends NPCGroundState

func physics_update(delta: float) -> void:
	apply_drag(0, delta)
	if npc.target:
		npc.face_target(delta)

func enter(previous_state: State, data := {}) -> void:
	super(previous_state, data)
	
	if npc.block:
		if npc.block.blocking:
			npc.animate_ground("Block")
			return
	npc.animate_ground("Idle")
