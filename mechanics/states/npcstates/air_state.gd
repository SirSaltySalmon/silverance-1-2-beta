class_name NPCAirState
extends NPCState

func update(delta: float) -> void:
	if npc.is_on_floor():
		next_state.emit("Idle")

func enter(_previous_state: State, _data := {}) -> void:
	npc.behavioral_tree.active = false
	npc.anim_sm.travel("AirStates")

func exit():
	npc.behavioral_tree.active = true
	npc.behavioral_tree.restart()

func apply_freefall_movement(target_velocity: Vector3, delta: float):
	apply_movement(target_velocity, delta, npc.air_accel, npc.air_turn_speed)
