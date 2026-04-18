class_name NPCGroundState
extends NPCState

func physics_update(delta: float) -> void:
	apply_drag(0, delta)
	if npc.target:
		npc.face_target(delta)

func enter(_previous_state: State, _data := {}) -> void:
	npc.anim_sm.travel("GroundStates")
	npc.animate_insta("Ground")

func exit() -> void:
	pass
