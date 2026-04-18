extends PlayerGroundState

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	apply_drag(0.0, delta)
	player.face_opposite_velocity_direction(delta)

func enter(_previous_state: State, _data := {}) -> void:
	# Died, more logic later for respawns and the such.
	player.health.deplete()
	player.is_vulnerable_to_attacks = false
	player.target = null
	player.dead = true
	player.deathfang_hitbox.disable()
	# KnockDown anim is handled by transitioner
	
	Data.sav.death_counter += 1
	Data.autosave_active = false
	SoundManager.play_sfx("Death", 0.0, -5.0)
	player.died.emit()
	
	await Methods.wait(1.0)
	SignalBus.noun_verbed.emit("YOU DIED", Color.DARK_RED)
	await Methods.wait(3.0)
	
	await player.screen_effects.fade_to_black()
	player.ready_for_respawn.emit()

func exit() -> void:
	print_debug("Death should not be able to be exited, find error")
