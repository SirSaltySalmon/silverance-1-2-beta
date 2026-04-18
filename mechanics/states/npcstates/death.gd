extends NPCState

@export var time_before_despawning := 1.5

func physics_update(delta: float) -> void:
	apply_drag(0, delta)

func enter(_previous_state: State, _data := {}) -> void:
	npc.behavioral_tree.active = false
	
	npc.health.deplete()
	npc.is_staggered = false
	npc.engaged = false
	npc.is_vulnerable_to_attacks = false
	npc.dead = true
	npc.target = null
	Data.sav.dead_id.append(npc.id)
	
	npc.anim_sm.travel("KnockDown")
	
	if npc.loot_money > 0:
		Data.sav.money += npc.loot_money
		SignalBus.money_updated.emit()
	if npc is BaseBoss:
		Data.sav.boss_flags[npc.flag] = true
	
	npc.died.emit()
	await Methods.wait(time_before_despawning)
	
	if npc.loot_id != -1 and npc.loot_type != Data.LootType.NULL:
		# If flagged, skip if already picked up — otherwise fall through
		if npc.loot_flag != "" and Data.sav.loot_flags[npc.loot_flag]:
			pass # Loot already collected, do nothing
		else:
			# Roll for chance-based loot (1.0 = guaranteed, always passes)
			if npc.loot_chance == 1.0 or randf() <= npc.loot_chance:
				Data.game.create_loot(npc.loot_id, npc.loot_type, npc.global_position, npc.loot_flag)
	
	if npc is BaseBoss:
		if npc.to_detach_from:
			npc.to_detach_from.detach(npc)
		SignalBus.noun_verbed.emit("ENEMY FELLED", Color.GOLD)
		SoundManager.play_sfx("Death", 0.0, -5.0)
	
	npc.queue_free()
