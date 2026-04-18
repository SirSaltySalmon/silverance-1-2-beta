extends PlayerGroundState

@onready var StunTimer: Timer = $StunTimer

func handle_input(_event: InputEvent) -> void:
	## Stunned
	pass

func update(_delta: float) -> void:
	if not player.is_on_floor():
		next_state.emit("Falling")

func physics_update(delta: float) -> void:
	apply_drag(0.0, delta)
	player.face_opposite_velocity_direction(delta)

func enter(_previous_state: State, _data := {}) -> void:
	player.hit_counter += 1
	player.anim_tree["parameters/DamagedStates/HitStunOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	player.effects.stun()
	StunTimer.start(player.hit_stun_duration)
	return

func exit() -> void:
	StunTimer.stop()
	player.anim_tree["parameters/DamagedStates/HitStunOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT

func _on_stun_timer_timeout() -> void:
	player.hit_counter = 0
	if player.is_on_floor():
		next_state.emit("Idle")
	else:
		next_state.emit("Falling")
