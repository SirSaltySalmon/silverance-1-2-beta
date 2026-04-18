extends PlayerGroundState

@onready var StunTimer: Timer = $StunTimer
@onready var RecoveryTimer: Timer = $RecoveryTimer

var can_recover := false
var recovered := false

func handle_input(event: InputEvent) -> void:
	if can_recover and event.is_action_released("dodge"):
		recovered = true
		next_state.emit("Dodge")
	pass

func update(_delta: float) -> void:
	if not player.is_on_floor():
		next_state.emit("Falling")

func physics_update(delta: float) -> void:
	apply_drag(0.0, delta)
	player.face_opposite_velocity_direction(delta)

func enter(_previous_state: State, _data := {}) -> void:
	can_recover = false
	player.is_vulnerable_to_attacks = false
	player.armour.reset()
	## Give i-frames for recovery
	StunTimer.start(player.knock_down_duration)
	pass

func exit() -> void:
	## i-frames are over
	StunTimer.stop()
	RecoveryTimer.stop()
	player.is_vulnerable_to_attacks = true
	pass

func _on_stun_timer_timeout() -> void:
	can_recover = true
	player.anim_sm.travel("Recovery")
	RecoveryTimer.start(player.knock_down_recovery)

func _on_recovery_timer_timeout() -> void:
	if player.is_on_floor():
		next_state.emit("Idle")
	else:
		next_state.emit("Falling")
