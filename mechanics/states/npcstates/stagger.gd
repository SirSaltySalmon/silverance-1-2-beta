extends NPCState

@onready var StunTimer: Timer = $StunTimer

var dies_after_staggering := false

func update(_delta: float):
	if not npc.is_on_floor():
		next_state.emit("AirState")

func physics_update(delta: float) -> void:
	apply_drag(0.0, delta)

func enter(_previous_state: State, data := {}) -> void:
	npc.behavioral_tree.active = false
	
	npc.anim_sm.travel("DamagedStates")
	npc.anim_tree["parameters/DamagedStates/StaggerOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	if data:
		dies_after_staggering = data["dies"]
	npc.effects.stagger()
	npc.is_staggered = true
	StunTimer.start(npc.stagger_duration)
	return

func exit() -> void:
	npc.behavioral_tree.active = true
	npc.behavioral_tree.restart()
	
	npc.is_staggered = false
	StunTimer.stop()
	npc.anim_tree["parameters/DamagedStates/StaggerOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT

func _on_stun_timer_timeout() -> void:
	if dies_after_staggering:
		next_state.emit("Death")
		return
	
	if npc.is_on_floor():
		next_state.emit("Idle")
	else:
		next_state.emit("AirState")
