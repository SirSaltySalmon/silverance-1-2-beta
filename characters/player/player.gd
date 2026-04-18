class_name Player
extends Character

signal loadout_changed(main_res: WeaponRes, sheathed_res: WeaponRes)
signal weapon_equipped(equipped_weapons: Array[Weapon])
signal accessory_changed(res_arr: Array[AccessoryRes])
signal ready_for_respawn

## By doing ":=" you essentially also type the variable with the value you just gave it
@export_group("Player Movement")
@export var max_speed_run := 7.5
@export var jump_impulse := 5.0
@export var dodge_impulse := 15.0
@export var stamina_use_rate := 50.0
@export var stamina_refill_rate := 20.0
@export var dodge_time := 0.7
@export var dodge_invul_time := 0.45
@export var parry_time := 0.3
@export var weapon_switch_cd_time := 0.3

@export_group("Nodes")
var game: AbstractGameScene
@export var camera: ThirdPersonCamera
@export var last_ground_location: LastGroundLocation
@export var recently_dodged_timer: Timer
@export var stamina: StaminaComponent
@export var target_indicator: Sprite3D
@export var deathfang_hitbox: DeathfangHitbox
@export var weapon_switch_cd: Timer
@export var interaction_alert: InteractionAlert
@export var game_menus: GameMenus
@export var screen_effects: ScreenEffects
@export var boss_bars: BossBarsDisplayer

@onready var anim_sm = anim_tree["parameters/playback"]

## Store directional inputs
var camera_transform_angle : float
var input_dir_2d := Vector2()
var input_dir := Vector3()

## Buffer inputs
var attack_buffer = Buffer.new(0.3, 0.0, false)
var dodge_buffer = Buffer.new(0.3, 0.0, false)
var switch_buffer = Buffer.new(0.3, 0.0, false)

## Interaction management
var interactables: Array[Interactable] = []
var object_to_interact: Interactable = null

## Accessories, similar to weapons
var equipped_accessories_nodes: Array[Accessory] = []
var equipped_accessories_scenes: Array[PackedScene] = []

@onready var heals_left = Data.sav.max_heals

func _ready() -> void:
	Data.connect("preparing_to_save", save_helper)
	SignalBus.connect("rest_prepare", _on_rest_prepare)
	connect("died", game._prepare_for_respawn)
	Data.player = self
	load_from_saves()
	super()
	camera.set_camera_behind_player()
	%ScreenEffects.fade_to_clear()
	print(global_position)
	
	if game.resting:
		SignalBus.emit_signal("rested")

func _on_rest_prepare():
	state_machine.transition_to_next_state("SittingDown")

func load_from_saves():
	## Auto-save only happen when you are not in combat. Logic in these saves will be reflected as so.
	load_stats()
	load_weapons()
	load_and_equip_accessories()

func load_stats():
	global_position = Data.sav.player_global_position
	_set_rig_transform(Data.sav.player_rig_transform_basis)
	rig.scale = Vector3(0.75,0.75,0.75)
	health.update_maxmin_values(Data.sav.max_health, 0)
	health.value = Data.sav.health
	## Poise and armour regen automatically over time so can just be reset to max value
	poise.update_maxmin_values(Data.sav.max_poise, 0)
	poise.value = Data.sav.max_poise
	armour.update_maxmin_values(Data.sav.max_armour, 0)
	armour.value = Data.sav.max_poise

func save_helper():
	Data.sav.player_global_position = global_position
	Data.sav.player_rig_transform_basis = _get_rig_transform()
	Data.sav.max_health = health.max_health
	Data.sav.health = health.value
	Data.sav.max_poise = poise.max_poise
	Data.sav.max_armour = armour.max_armour
	Data.sav.blood_meter = blood.get_value()

func load_weapons():
	active_weapon_scene.clear()
	var main_res: WeaponRes
	var sheathed_res: WeaponRes
	
	if Data.sav.equipped_active != -1:
		main_res = Data.sav.arsenal[Data.sav.equipped_active]
		var paths = main_res.path
		for each_path in paths:
			active_weapon_scene.append(load(each_path))
	
	sheathed_weapon_scene.clear()
	if Data.sav.equipped_sheathed != -1:
		sheathed_res = Data.sav.arsenal[Data.sav.equipped_sheathed]
		var paths = sheathed_res.path
		for each_path in paths:
			sheathed_weapon_scene.append(load(each_path))
	# Use the weapon resources
	
	loadout_changed.emit(main_res, sheathed_res)

func update_weapon_equipment():
	unequip_weapon()
	load_weapons()
	equip_weapon(active_weapon_scene)
	_animate_switch_weapon()

func equip_weapon(weapon_to_equip_scene: Array[PackedScene] = []) -> void:
	super(weapon_to_equip_scene)
	weapon_equipped.emit(equipped_weapon_nodes)
	

func try_trigger_special():
	if equipped_weapon_nodes == []:
		return
	var special: Special = equipped_weapon_nodes[0].special_node
	if special == null:
		return
	special.try_trigger()

func unequip_accessories():
	for acc in equipped_accessories_nodes:
		acc.remove_passive()
		acc.queue_free()
	equipped_accessories_nodes = []

func load_and_equip_accessories():
	var res_arr: Array[AccessoryRes] = [null, null, null] ## Needed for updating icons
	for i in range(len(Data.sav.equipped_acc)):
		if Data.sav.equipped_acc[i] != -1:
			var index = Data.sav.equipped_acc[i]
			res_arr[i] = Data.sav.accessories[index]
	
	for i in range(len(res_arr)):
		var acc_res: AccessoryRes = res_arr[i]
		if acc_res != null:
			var scene = load(acc_res.path)
			var instance: Accessory = scene.instantiate()
			instance.slot = i
			instance.wearer = self
			self.add_child(instance)
			equipped_accessories_nodes.append(instance)
			instance.trigger_passive()
	
	accessory_changed.emit(res_arr)

func update_accessory_equipment():
	unequip_accessories()
	load_and_equip_accessories()

func is_in_combat() -> bool:
	return not pursued_by.is_empty()

func _process(delta) -> void:
	## Get directional inputs and put it in a 3D Vector. Rotate it by camera's
	## rotation to make the input accurate for the player's perspective.
	camera_transform_angle = camera.camera_target.global_transform.basis.get_euler().y
	input_dir_2d = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	input_dir = _calculate_3d_dir(input_dir_2d, camera_transform_angle)
	
	## Update the buffer
	attack_buffer.update(Input.is_action_just_released("attack"), true, delta)
	dodge_buffer.update(Input.is_action_just_released("dodge"), true, delta)
	switch_buffer.update(Input.is_action_just_released("switch_weapons"), true, delta)
	# Note: Attacks buffer are only checked in Dodge, Charging and Attack
	# as they won't matter anywhere else
	
	## Check for items that can be interacted
	check_interactables()
	
	## Rotate the rig

func _unhandled_input(event: InputEvent) -> void:
	## Handles locking on
	handle_heal(event)
	handle_lock_on(event)
	handle_interaction(event)

func handle_heal(event: InputEvent) -> void:
	if event.is_action_pressed("heal") and not dead:
		if heals_left > 0:
			heals_left -= 1
			heal()

func heal():
	effects.heal()
	health.heal()

func handle_lock_on(event: InputEvent) -> void:
	if event.is_action_pressed("lock_on"):
		if target:
			lock_out_of_target()
		else:
			target = camera.get_nearest_visible_target(target)
			if not target:
				camera.position_camera_behind_player()
			else:
				lock_onto_a_set_target()

func handle_interaction(event: InputEvent): 
	if not event.is_action_pressed("interact"):
		return
	if object_to_interact:
		object_to_interact.interact()

func check_interactables():
	if interactables.is_empty():
		object_to_interact = null
		interaction_alert.hide()
		return
	object_to_interact = Methods.get_closest(self, interactables)
	interaction_alert.update(object_to_interact.text)

func lock_out_of_target():
	target = null
	target_indicator.hide()
	target_indicator.reparent(self)

func lock_onto_a_set_target():
	## Target must already be set into the target variable
	target_indicator.show()
	target_indicator.reparent(target)
	if target.custom_target_indicator_pos:
		target_indicator.position = target.custom_target_indicator_pos
	else:
		target_indicator.position = Vector3(0, 1.2, 0)

func should_face_target() -> bool:
	return target and not state_machine.state.name in ["Run", "Attack"]

func should_rotate_by_input() -> bool:
	## For states that need extra maneuverability even if character isn't moving
	return input_dir != Vector3.ZERO and (
		(state_machine.state.name in ["Charging", "Jump", "Falling"])
		or
		(state_machine.state.name == "Attack" and not attacking))

func should_face_velocity_opposite_direction():
	return state_machine.state.name in ["Stun", "BlockHit", "Parry", "Stagger", "KnockDown", "AirHit", "Death"]

func should_face_velocity_direction() -> bool:
	return (velocity.x != 0.0 and velocity.z != 0.0) and not state_machine.state.name in ["Idle"]

func face_input_direction(delta):
	face_direction(delta, input_dir)

func face_velocity_direction(delta):
	face_direction(delta, velocity)

func face_opposite_velocity_direction(delta):
	face_direction(delta, -velocity)

func face_target_if_possible(delta, is_idle := false):
	if target != null:
		face_target(delta)
	elif not is_idle:
		face_velocity_direction(delta)

func block_condition() -> bool:
	return Input.is_action_pressed("block") and state_machine.state.name in ["Idle", "Walk", "BlockHit"]

func block_animation_enable() -> void: 
	if state_machine.state.has_method("block_animation_enable"):
		state_machine.state.block_animation_enable()

func block_animation_disable() -> void:
	if state_machine.state.has_method("block_animation_disable"):
		state_machine.state.block_animation_disable()

func damaging_fall_behavior():
	camera.falling = true
	var last_location := last_ground_location.global_position
	# Takes away 1/4 of max health every fall
	var dies_by_falling := health.generic_damage(health.max_value / 4)
	if dies_by_falling:
		state_machine.transition_to_next_state("Death")
	else:
		await Methods.wait(0.5)
		await screen_effects.fade_to_black()
		velocity = Vector3.ZERO
		global_position = last_location
		camera.falling = false
		screen_effects.fade_to_clear()

func _negate_gravity() -> void:
	gravity_applied = false
	velocity.y = 0

func _apply_gravity() -> void:
	gravity_applied = true

func _can_start_floating() -> bool:
	## If you can float for at least 0.5 seconds with the current stamina
	if stamina.get_value() >= (stamina_use_rate / 2.0):
		return true
	return false

func _make_invul_to_attacks() -> void:
	is_vulnerable_to_attacks = false

func _make_vulnerable_to_attacks() -> void:
	is_vulnerable_to_attacks = true

func _is_recently_dodged() -> bool:
	return not recently_dodged_timer.is_stopped()

func on_target_death():
	lock_out_of_target()

func air_hit(is_health_depleted := false):
	## Fall down, then knockdown if not death otherwise play death
	state_machine.transition_to_next_state("AirHit", {"dies" = is_health_depleted})
	pass

func health_depleted_death():
	state_machine.transition_to_next_state("Death")
	pass

func stagger():
	## Play stagger state for Deathfang
	## Await poise recover, then go back to normal
	state_machine.transition_to_next_state("Stagger")
	pass

func blockhit():
	state_machine.transition_to_next_state("BlockHit")
	pass

func parry():
	state_machine.transition_to_next_state("Parry")
	pass

func stun():
	## If hit 3 times when stunned, automatically knocked down to prevent stun-locking,
	## Avoid frustrating player
	if hit_counter >= 3:
		state_machine.transition_to_next_state("KnockDown")
		return
	state_machine.transition_to_next_state("Stun")
	return

func bleed():
	effects.bleed()

func switch_weapons():
	weapon_switch_cd.start(weapon_switch_cd_time)
	_animate_switch_weapon()
	
	var temp = Data.sav.equipped_active
	Data.sav.equipped_active = Data.sav.equipped_sheathed
	Data.sav.equipped_sheathed = temp
	
	super()

func _animate_switch_weapon():
	if state_machine.state.name in ["Attack"]:
		return
	anim_tree["parameters/GroundStates/SwitchWeaponOneShot/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
