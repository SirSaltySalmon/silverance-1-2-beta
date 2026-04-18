extends PlayerGroundState

var campfire_pos: Vector3

func handle_input(event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	# Apply drag. Multiplied by 2 to make stopping more responsive
	apply_drag(0.0, delta * 2)
	player.face_position(delta, campfire_pos)
	

func enter(_previous_state: State, data := {}) -> void:
	campfire_pos = Data.sav.rest_locations[Data.sav.last_rested][2]
	animate_ground("SittingDown")
	player.anim_tree.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim):
	next_state.emit("Rest")

func exit() -> void:
	campfire_pos = Vector3.ZERO
