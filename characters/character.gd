class_name Character extends CharacterBody3D

@export_group("Movement Data")
@export var accel := 20.0
@export var max_speed_walk := 2.0
@export var terminal_velocity := 20
@export var turn_speed := 5.0
@export var air_accel := 0.0
@export var air_turn_speed := 1.0

## Determines if gravity is being applied. Modified by helper functions
var gravity_applied := true
## Determines if can take damage while dodging. Modified by helper functions
## A separate variable rather than just disabling damage, as may still be affected
## By fall damage, status effects, etc.
var is_vulnerable_to_attacks := true

@export_group("Combat Data")
enum Teams {PLAYER, ENEMY, ENEMY_2}
@export var team: Teams
@export var knockback_value := 1.0
@export var hit_stun_duration := 0.4
@export var block_hit_duration := 0.3
@export var stagger_duration := 1.5
@export var knock_down_duration := 2.0
@export var knock_down_recovery := 1.0
@export var attack_impulse := 10.0
@export var custom_target_indicator_pos: Vector3

## Store information to decide which attacks to play
@export_group("Weapon Data")
signal weapon_switched
var combo_counter := 0
@export_enum(
	"BASIC_0",
	"BASIC_1",
	"BASIC_2",
	"RUNNING",
	"DODGE",
	"CHARGED",
	"PLUNGE",
) 	var attack_type: String
@export_enum(
	"1H",
	"2H",
	"DW",
	"UNARMED"
) 	var weapon_type: String
## Used to instantiate the weapon
@export var active_weapon_scene: Array[PackedScene]
@export var sheathed_weapon_scene: Array[PackedScene]

## Points to the instantiated weapon
var equipped_weapon_nodes: Array[Weapon]

@export_group("Multipliers")
## Multipliers for taking and receiving damage.
# Certain enemies may take/deal less damage or more damage
# Player equipment or weapons can manipulate the multiplier.
var damage_mults: Array[Multiplier]
var resistance_mults: Array[Multiplier]

@export var general_dmg_mult := 1.00
@export var health_dmg_mult := 1.00
@export var poise_dmg_mult := 1.00
@export var armour_dmg_mult := 1.00

@export var general_res_mult := 1.00
@export var health_res_mult := 1.00
@export var poise_res_mult := 1.00
@export var armour_res_mult := 1.00

@export_group("Nodes")
@export var dummy_rig: Node3D
@export var health: HealthComponent
@export var armour: ArmourComponent
@export var poise: PoiseComponent
@export var block: BlockComponent
@export var blood: BloodMeterComponent
@export var rig: Node3D
@export var skeleton: Skeleton3D
@export var anim_player: AnimationPlayer
@export var anim_tree: AnimationTree
@export var state_machine: StateMachine
@export var effects: EffectsManager

## Signal to help apply impulse when attack is thrown
signal attack_launched
## Signal to help NPCs update itself with new targets when hit by a different enemy
signal hit
## Signal to help display mults
signal mult_updated(type: String)
## Signal to help with removing from targetting and enemy AI
signal died

var dead = false

## Helps to identify if a character is in combat
var pursued_by: Array[Character] = []
var last_target: Character

## Handle locking on for character, and enemy's attack target if enemy
@export var target: Character:
	set(chara):
		if chara != null:
			if last_target:
				if is_instance_valid(last_target):
					last_target.disconnect("died", on_target_death)
			last_target = chara
			if not self in chara.pursued_by:
				chara.pursued_by.append(self)
			chara.connect("died", on_target_death)
		else:
			if last_target != null:
				if is_instance_valid(last_target):
					last_target.pursued_by.erase(self)
		target = chara
## Flag that turns on every time a hitbox is triggered, help handle facing target
var attacking := false
## Count how many hits taken in the last interaction, helps AI decide next action and such
var hit_counter := 0
## Var to track if currently staggered to save on performance
var is_staggered := false

func _ready() -> void:
	equip_weapon(active_weapon_scene) ## TODO: In function

func _physics_process(delta) -> void:
	if not is_on_floor() and gravity_applied:
		velocity.y += get_gravity().y * delta
	
	move_and_slide()

func equip_weapon(weapon_to_equip_scene: Array[PackedScene] = []) -> void:
	if weapon_to_equip_scene.is_empty():
		weapon_type = "UNARMED"
		return
	
	var weapon_counter = 0
	for each_weapon_scene in active_weapon_scene:
		var weapon_instance: Weapon = each_weapon_scene.instantiate()
		equipped_weapon_nodes.append(weapon_instance)
		weapon_instance.wielder = self
		if weapon_counter == 0:
			weapon_type = weapon_instance.weapon_type
			weapon_instance.trigger_passive()
		weapon_instance.name = "Weapon" + str(weapon_counter)
		skeleton.add_child(weapon_instance)

func unequip_weapon():
	if equipped_weapon_nodes.is_empty():
		return
	equipped_weapon_nodes[0].remove_passive()
	for weapon in equipped_weapon_nodes:
		weapon.queue_free()
	equipped_weapon_nodes = []

func switch_weapons():
	unequip_weapon()
	
	## LIMITATION - Cannot add bone to model to physically display a sheathed weapon. Too bad!
	## Gonna have to do that with my own model.
	var temp = sheathed_weapon_scene
	sheathed_weapon_scene = active_weapon_scene
	active_weapon_scene = temp
	
	equip_weapon(active_weapon_scene)
	weapon_switched.emit()

func enable_hitbox(index: int = 0):
	attack_launched.emit()
	attacking = true
	if equipped_weapon_nodes:
		equipped_weapon_nodes[index]._enable_hitbox()

func enable_all_hitbox():
	attack_launched.emit()
	attacking = true
	for weapon in equipped_weapon_nodes:
		weapon._enable_hitbox()

func disable_hitbox(index: int = 0):
	attacking = false
	if equipped_weapon_nodes:
		equipped_weapon_nodes[index]._disable_hitbox()

func disable_all_hitbox():
	attacking = false
	for weapon in equipped_weapon_nodes:
		weapon._disable_hitbox()

func retrigger_hitbox(index: int = 0):
	## Does not emit attack launched
	attacking = true
	equipped_weapon_nodes[index]._retrigger_hitbox()

func reset_weapon() -> void:
	attacking = false
	for weapon in equipped_weapon_nodes:
		weapon._reset_weapon()

func disable_weapon() -> void:
	attacking = false
	for weapon in equipped_weapon_nodes:
		weapon._disable_weapon()

func connected_attack(is_parried: bool, parrier: Character = null):
	if is_parried:
		return take_parry_damage(parrier)
	hit_counter = 0

func receive_attack(damage: int, kb: float, attacker: Character, is_unblockable := false, is_unparriable := false) -> void:
	## Negate damage if in invincibility frames
	if not is_vulnerable_to_attacks:
		return
	
	hit.emit(attacker)
	# Advanced combat logic here to see if an attack should be blocked or parried automatically by an NPC
	hit_counter_checks() 
	
	## Else, count as a connected attack
	if not is_unparriable and block.can_parry():
		block.on_successful_parry() 
		var attacker_staggered = attacker.connected_attack(true, self)
		parry()
		if not attacker_staggered:
			apply_knockback(attacker, kb)
		return # Parry completes and user negates damage, does not continue
	
	apply_knockback(attacker, kb)
	attacker.connected_attack(false)
	
	if state_machine:
		if state_machine.state.name != "Attack":
			hit_counter += 1
	
	if is_unblockable:
		deal_damage(damage, attacker, ["Block"])
	else:
		deal_damage(damage, attacker)
	return

func hit_counter_checks():
	## To be overloaded by subclasses
	pass

func deal_damage(damage: int, attacker: Character, ignore_receiver_mults := [], ignore_attacker_mults := []):
	## If this function is triggered without using receive_attack, it can be used to force damage
	## on a character regardless of invincibility frames. In that case, set attacker to null
	## to apply 0 knockback.

	calculate_multiplier("res", ignore_receiver_mults)
	if attacker:
		attacker.calculate_multiplier("dmg", ignore_attacker_mults)

	var final_dmg := damage * attacker.general_dmg_mult * general_res_mult
	var health_dmg := int(final_dmg * attacker.health_dmg_mult * health_res_mult)
	var poise_dmg := int(final_dmg * attacker.poise_dmg_mult * poise_res_mult)
	var armour_dmg := int(final_dmg * attacker.armour_dmg_mult * armour_res_mult)
	
	## The generic damage functions return true if depleted within this attack
	var is_health_depleted = health.generic_damage(health_dmg)
	var is_poise_broken = poise.generic_damage(poise_dmg)
	var is_armour_broken = armour.generic_damage(armour_dmg)
	
	## Simple indication of having to take health damage, apply to different states
	if health_dmg > 0:
		effects.bleed()
	
	if not is_on_floor():
		air_hit(is_health_depleted)
		return
		## Pass in is_health_depleted to trigger death immediately after falling down.
	
	if is_health_depleted:
		health_depleted_death() ## Allow for Deathfang, then dies
		return
	## Special behavior for player
	if self is Player:
		if state_machine.state.name == "Stagger":
			state_machine.transition_to_next_state("KnockDown")
			return
	
	if is_poise_broken:
		stagger() ## Allow for Deathfang but will recover if not killed
		return
	if block.can_block() and not ("Block" in ignore_receiver_mults):
		blockhit() ## Play block animation
		return 
	if is_armour_broken:
		stun() ## Stun
		return

func take_parry_damage(parrier: Character):
	## Simplified version of deal damage just to take parry damage
	calculate_multiplier("res")
	parrier.calculate_multiplier("dmg")
	const PARRY_DAMAGE := 10.0 ## Base poise damage valued taken for getting parried on
	var poise_dmg := int(PARRY_DAMAGE * parrier.poise_dmg_mult * poise_res_mult)
	var is_poise_broken = poise.generic_damage(poise_dmg)
	
	if is_poise_broken:
		apply_knockback(parrier)
		stagger()
		return true
	
	return false

func calculate_multiplier(type: String, ignore_mults := []) -> void:
	set_mults_to_one()
	
	if type == "dmg":
		for mult in damage_mults:
			if mult.name in ignore_mults:
				continue
			match mult.type:
				"General":
					general_dmg_mult += mult.value
				"Health":
					health_dmg_mult += mult.value
				"Poise":
					poise_dmg_mult += mult.value
				"Armour":
					armour_dmg_mult += mult.value
	elif type == "res":
		for mult in resistance_mults:
			if mult.name in ignore_mults:
				continue
			match mult.type:
				"General":
					general_res_mult -= mult.value
				"Health":
					health_res_mult -= mult.value
				"Poise":
					poise_res_mult -= mult.value
				"Armour":
					armour_res_mult -= mult.value
		## Cap res at 0.0, else each hit will heal health if res is high enough
		general_res_mult = max(general_res_mult, 0.0)
		health_res_mult = max(health_res_mult, 0.0)
		poise_res_mult = max(poise_res_mult, 0.0)
		armour_res_mult = max(armour_res_mult, 0.0)
	else:
		printerr("Invalid mult type 2")

func set_mults_to_one() -> void:
	general_dmg_mult = 1.00
	health_dmg_mult = 1.00
	poise_dmg_mult = 1.00
	armour_dmg_mult = 1.00
	
	general_res_mult = 1.00
	health_res_mult = 1.00
	poise_res_mult = 1.00
	armour_res_mult = 1.00

func add_multiplier(pname: String, type: String, value: float, type2 := "General", duration := -1) -> void:
	## On death, respawn and equips, equippables are all triggered to give and remove the required mults
	if type == "res":
		resistance_mults.append(Multiplier.new(self, pname, value, type2, duration))
	elif type == "dmg":
		damage_mults.append(Multiplier.new(self, pname, value, type2, duration))
	else:
		printerr("Invalid mult type 1")
	mult_updated.emit(type)

func remove_multiplier(pname: String, type: String) -> void:
	var mults_array: Array
	if type == "res":
		mults_array = resistance_mults
	elif type == "dmg":
		mults_array = damage_mults
	else:
		printerr("Invalid mult type 1")
		return
	
	## Find and remove all matching multipliers (iterate backwards to avoid index issues)
	for i in range(mults_array.size() - 1, -1, -1): # This is syntax for backwards iteration
		if mults_array[i].name == pname:
			var mult_to_remove = mults_array.pop_at(i)
			mult_to_remove.queue_free()
	
	mult_updated.emit(type)

func remove_multiplier_by_ref(mult: Multiplier) -> void:
	resistance_mults.erase(mult)
	damage_mults.erase(mult)
	mult.queue_free()
	mult_updated.emit()

func has_multiplier(mult_name: String, type):
	if type == "res":
		return search_for_mult_in(mult_name, resistance_mults)
	elif type == "dmg":
		return search_for_mult_in(mult_name, damage_mults)
	else:
		return search_for_mult_in(mult_name, resistance_mults + damage_mults)

func search_for_mult_in(mult_name: String, mult_array: Array[Multiplier]):
	for mult in mult_array:
		if mult.name == mult_name:
			return true
	return false

func block_condition():
	pass ##TODO: Definitely refactor this later?

func apply_knockback(attacker: Character, multiplier := 1.0):
	if attacker == null:
		return
	## Get vector direction forward from attacker's rig_rotation
	var direction = (attacker._calculate_3d_dir(Vector2(0,1),attacker._get_rig_rotation().y))
	## Apply an impulse in this direction
	velocity = Vector3.ZERO
	velocity.x = direction.x * knockback_value * 5.0 * multiplier
	velocity.z = direction.z * knockback_value * 5.0 * multiplier

func on_target_death():
	target = null
	pass

func air_hit(is_health_depleted := false):
	## Fall down, then knockdown if not death otherwise play death
	pass

func health_depleted_death():
	## Play stagger state for Deathfang
	## When finishes, play death anim
	pass

func stagger():
	## Play stagger state for Deathfang
	## Await poise recover, then go back to normal
	pass

func blockhit():
	## Play blockhit state and recover immediately
	pass

func parry():
	## Play parry state and recover immediately, which is pretty much blockhit with different effects
	pass

func stun():
	## Play stun state and recover immediately
	pass

func bleed():
	## General effect for being attacked
	pass

func block_animation_enable() -> void:
	pass

func block_animation_disable() -> void:
	pass

func damaging_fall_behavior():
	pass

func is_on_same_team_as(chara: Character) -> bool:
	return team == chara.team

func is_on_team(pteam: Teams):
	return team == pteam

func face(delta, ptarget: Node3D):
	face_position(delta, ptarget.global_position)

func face_position(delta, position: Vector3):
	var rot = rig.global_transform.basis.get_euler()
	var target_rot = get_rotation_to(position)
	
	rig.global_rotation.y = lerp_angle(rot.y, target_rot.y, delta * turn_speed)

func face_target(delta: float) -> void:
	if attacking:
		return
	
	face(delta, target)

func face_direction(delta: float, direction: Vector3) -> void:
	direction.y = 0
	if direction.length() <= 0.05: # Stops small floating point errors from messing up direction in the end
		return
	var target_angle := get_angle_to_direction(direction)
	rig.global_rotation.y = lerp_angle(rig.global_rotation.y, target_angle, delta * turn_speed)

func get_angle_to_direction(direction: Vector3) -> float:
	return atan2(direction.x, direction.z)

func get_horizontal_velocity() -> Vector3:
	return Vector3(velocity.x, 0.0, velocity.z)

func get_rotation_to_target():
	return get_rotation_to(target.global_position)

func get_rotation_to(pos):
	dummy_rig.look_at(pos, Vector3.UP, true)
	return dummy_rig.global_transform.basis.get_euler()

func _get_rig_transform() -> Basis:
	return rig.global_transform.basis

func _get_rig_rotation() -> Vector3:
	return _get_rig_transform().get_euler()

func _set_rig_transform(pbasis: Basis) -> void:
	rig.global_transform.basis = pbasis

func _calculate_3d_dir(dir_2d: Vector2, y_rotation: float) -> Vector3:
	## Very useful helper function to give the direction vector relative to an object's rotation.
	## Eg. Punch in Vector2(0,1) and the y rotation of an object to get the vector
	## that faces forward from that object
	return (
		Vector3(dir_2d.x, 0, dir_2d.y)
		.rotated(Vector3.UP, y_rotation).normalized()
	)

func kill():
	health.deplete()
	state_machine.transition_to_next_state("Death")
