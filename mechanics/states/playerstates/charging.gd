extends PlayerGroundState

## Does not only act as a charging state but also a manager to make sure the player
## use the correct attack on execution
## If the attack is not charged, should ALWAYS prioritize performing a deathfang first

func handle_input(event: InputEvent) -> void:
	if event.is_action_released("attack"):
		
		## Example of prioritizing deathfang here
		if player.deathfang_hitbox.can_deathfang():
			next_state.emit("Deathfang")
			return
		
		next_state.emit("Attack")

func update(delta: float) -> void:
	if check_for_hold("attack", delta, 1.0):
		player.attack_type = "CHARGED"
		next_state.emit("Attack")

func physics_update(delta: float) -> void:
	# Apply drag. Multiplied by 2 to make stopping more responsive
	player.velocity.x = move_toward(player.velocity.x, 0, delta * 2 * player.accel)
	player.velocity.z = move_toward(player.velocity.z, 0, delta * 2 * player.accel)
	
	if player.target != null:
		player.face_target(delta)

func enter(previous_state: State, _data := {}) -> void:
	reset_hold_counter()
	animate_ground("Charging")
	
	if previous_state.name == "Run":
		
		if player.deathfang_hitbox.can_deathfang():
			next_state.emit("Deathfang")
			return
		
		player.attack_type = "RUNNING"
		next_state.emit("Attack")
		return
	
	if player._is_recently_dodged():
		player.attack_type = "DODGE"
		return
	
	player.attack_type = "BASIC_" + str(player.combo_counter)

func exit() -> void:
	pass
