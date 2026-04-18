extends NPCAirState

var dies_after_falling := false

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	if npc.is_on_floor():
		if dies_after_falling:
			next_state.emit("Death")
			return
		next_state.emit("KnockDown")

func physics_update(delta: float) -> void:
	apply_freefall_movement(Vector3(0,0,0), delta)

func enter(_previous_state: State, data := {}) -> void:
	npc.behavioral_tree.active = false
	npc.is_vulnerable_to_attacks = false
	npc.anim_sm.travel("AirHit")
	dies_after_falling = false
	if data:
		if data["dies"]:
			dies_after_falling = true

func exit():
	npc.behavioral_tree.active = true
	npc.behavioral_tree.restart()
