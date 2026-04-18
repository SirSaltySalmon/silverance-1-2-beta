extends PlayerGroundState

func handle_input(event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	# Apply drag. Multiplied by 2 to make stopping more responsive
	apply_drag(0.0, delta * 2)

func enter(_previous_state: State, _data := {}) -> void:
	animate_ground("StandingUp")
	player.anim_tree.animation_finished.connect(_on_animation_finished)
	
	if player.game_menus.is_opened:
		player.game_menus.close()

func _on_animation_finished(anim):
	next_state.emit("Idle")

func exit() -> void:
	player.anim_tree.animation_finished.disconnect(_on_animation_finished)
