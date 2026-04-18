extends NPCState

func physics_update(delta: float) -> void:
	pass

func enter(_previous_state: State, data := {}) -> void:
	npc.behavioral_tree.active = false
	
	npc.velocity = Vector3.ZERO
	npc.is_vulnerable_to_attacks = false
	assert(data, "Data must be present to get the player node")
	
	## Setup weapon and animations
	npc.disable_weapon()
	npc.anim_sm.travel("Subdued")
	
	## Tween to face target
	var player = data["player_node"]
	npc.target = player
	var target_y_rotation = npc.get_rotation_to_target().y
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(npc.rig, "global_rotation:y", target_y_rotation, 0.5)
	await Methods.wait(0.5)
	
	## Finish animation
	npc.apply_knockback(player, 3.0)
	npc.bleed()
	next_state.emit("Death")

func exit() -> void:	
	npc.is_vulnerable_to_attacks = true
	npc.target = null
