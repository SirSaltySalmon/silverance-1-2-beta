class_name NPCBlockHitState extends NPCState

@onready var StunTimer: Timer = $StunTimer

func update(_delta: float):
	if not npc.is_on_floor():
		next_state.emit("AirState")

func physics_update(delta: float) -> void:
	apply_drag(0.0, delta)

func enter(_previous_state: State, _data := {}) -> void:
	npc.behavioral_tree.active = false
	
	npc.anim_sm.travel("DamagedStates")
	npc.anim_tree["parameters/DamagedStates/BlockHitOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	play_block_effects()
	StunTimer.start(npc.block_hit_duration)
	return

func play_block_effects():
	npc.effects.blockhit()

func exit() -> void:
	npc.behavioral_tree.active = true
	npc.behavioral_tree.restart()
	
	StunTimer.stop()
	npc.anim_tree["parameters/DamagedStates/BlockHitOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT

func _on_stun_timer_timeout() -> void:
	if npc.is_on_floor():
		next_state.emit("Idle")
	else:
		next_state.emit("AirState")
