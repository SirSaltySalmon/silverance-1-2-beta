extends PlayerGroundState

@export var deathfang_sfx: AudioStreamPlayer
var target: BaseNPC

func handle_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	apply_drag(0, delta)
	player.face_target_if_possible(delta)

func enter(_previous_state: State, _data := {}) -> void:
	player.velocity = Vector3.ZERO
	player.is_vulnerable_to_attacks = false
	
	target = player.deathfang_hitbox.prioritized_deathfang
	## Enemy will handle their own death here, the rest of this code will only handle animations
	target.receive_deathfang(player)
	player.deathfang_hitbox.disable()

	## Setup weapon and animations
	player.disable_weapon()
	animate_insta("Attacks")
	_attack_animation("DEATHFANG_STARTUP")
	
	## Tween to face target
	player.target = target 
	player.lock_onto_a_set_target()
	player.target_indicator.hide()
	var target_y_rotation = player.get_rotation_to_target().y
	player.camera.zoom_in()
	# Camera will lerp itself back when you exit Deathfang
	
	var direction = (player._calculate_3d_dir(Vector2(0,1),player.get_rotation_to_target().y))
	# Failsafe to make sure the player is launched into the direction of the NPC if
	# for whatever reason they aren't facing them.
	
	await Methods.wait(0.5)
	
	## Finish animation
	player.camera.zoom_out()
	_attack_animation("DEATHFANG_HIT")
	player.velocity.x = direction.x * player.attack_impulse
	player.velocity.z = direction.z * player.attack_impulse
	SignalBus.shake_camera.emit()
	deathfang_sfx.play()
	player.health.heal_deathfang()
	player.poise.heal_deathfang()
	await player.anim_tree.animation_finished
	
	## Cleanup
	player.reset_weapon()
	player.anim_tree["parameters/GroundStates/insta_trans/transition_request"] = "Ground"
	player.lock_out_of_target()
	player.deathfang_hitbox.enable()
	target = null
	
	next_state.emit("Idle")

func exit() -> void:
	player.is_vulnerable_to_attacks = true
	
