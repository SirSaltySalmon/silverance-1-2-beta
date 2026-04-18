extends PlayerAirState

var dies_after_falling := false

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	if player.is_on_floor():
		if dies_after_falling:
			next_state.emit("Death")
			return
		next_state.emit("KnockDown")

func physics_update(delta: float) -> void:
	apply_freefall_movement(Vector3(0,0,0), delta)
	player.face_opposite_velocity_direction(delta)

func enter(_previous_state: State, data := {}) -> void:
	player.is_vulnerable_to_attacks = false
	player.anim_sm.travel("AirHit")
	dies_after_falling = false
	if data:
		if data["dies"]:
			dies_after_falling = true
	pass

func exit() -> void:
	pass
