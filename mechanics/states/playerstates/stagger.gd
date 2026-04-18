extends PlayerGroundState

## Special behavior in character.gd code to knock player down if they take damage during stagger.

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
	player.is_staggered = true
	player.anim_tree["parameters/DamagedStates/StaggerOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	player.effects.stagger()
	StunTimer.start(player.stagger_duration)

func exit() -> void:
	player.is_staggered = false
	StunTimer.stop()
	player.anim_tree["parameters/DamagedStates/StaggerOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT

func _on_stun_timer_timeout() -> void:
	if player.is_on_floor():
		next_state.emit("Idle")
	else:
		next_state.emit("Falling")
