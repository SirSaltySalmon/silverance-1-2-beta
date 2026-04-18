extends NPCState

@onready var StunTimer: Timer = $StunTimer
@onready var RecoverTimer: Timer = $RecoveryTimer

func update(_delta: float):
	if not npc.is_on_floor():
		next_state.emit("AirState")

func physics_update(delta: float) -> void:
	apply_drag(0.0, delta)

func enter(_previous_state: State, _data := {}) -> void:
	npc.behavioral_tree.active = false
	
	npc.is_vulnerable_to_attacks = false
	npc.anim_sm.travel("KnockDown")
	StunTimer.start(npc.knock_down_duration)
	return

func exit() -> void:
	npc.behavioral_tree.active = true
	npc.behavioral_tree.restart()
	
	npc.is_vulnerable_to_attacks = true
	StunTimer.stop()

func _on_stun_timer_timeout() -> void:
	npc.anim_sm.travel("Recovery")
	RecoverTimer.start(npc.knock_down_recovery)	

func _on_recovery_timer_timeout() -> void:
	next_state.emit("Idle")
	
