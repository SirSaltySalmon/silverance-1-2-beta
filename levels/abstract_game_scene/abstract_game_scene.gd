class_name AbstractGameScene
extends Node3D

@export var player_scene: PackedScene
@export var loot_scene: PackedScene
@export var level_loader: LevelLoader

var player: Player
var resting := false
var should_open_menu_after_rest := true

func _ready() -> void:
	print("_ready called on: ", get_path(), " | instance: ", get_instance_id())
	Data.game = self
	SignalBus.connect("rest_prepare", _on_rest_prepare)
	SignalBus.connect("rested", _on_rested)
	if Data.sav.last_rested == "": # New game
		enter_new_location(Data.sav.current_level_index)
	else:
		load_last_save()

func enter_new_location(index: int):
	Data.sav.current_level_index = index
	await load_level()
	enter_new_level()
	should_open_menu_after_rest = false
	await reload_player()

func load_last_save():
	await load_level()
	await reload_player()

func reload_level():
	level_loader.reload_level()
	await level_loader.level_ready
	return

func reload_player():
	if is_instance_valid(player):
		player.queue_free()
	player = player_scene.instantiate()
	player.game = self
	level_loader.current_level.add_child(player)
	await player.ready
	return

func load_level():
	level_loader.load_level()
	await level_loader.level_ready
	return

func _on_rest_prepare():
	await player.screen_effects.fade_to_black()
	
	Data.autosave_active = false
	player.global_position = Data.sav.rest_locations[Data.sav.last_rested][0]
	reset_world_stats()
	
	resting = true
	await reload_level()
	await reload_player()

func reset_world_stats():
	player.health.restore()
	player.poise.restore()
	player.armour.restore()
	Data.clear_dead_id()
	Data.save()

func _on_rested():
	resting = false
	
	orient_player()
	
	if should_open_menu_after_rest:
		player.game_menus.open(true)
	
	if Data.new_campfire_lit:
		SignalBus.noun_verbed.emit("CAMPFIRE LIT", Color.GOLD)
		Data.new_campfire_lit = false
		SoundManager.play_sfx("CampfireLit", 0.0, 0.0)
	
	Data.autosave_active = true
	Data.autosave_remaining = 0
	should_open_menu_after_rest = true

func orient_player():
	var campfire_data = Data.sav.rest_locations[Data.sav.last_rested]
	player.rig.look_at(campfire_data[2])
	player.camera.set_camera_in_front_of_player()

func _prepare_for_respawn():
	Data.autosave_active = false
	
	await player.ready_for_respawn
	reset_world_stats()
	set_player_location_to_last_rest()
	await reload_level()
	await reload_player()
	orient_player()
	
	Data.autosave_active = true
	Data.autosave_remaining = 0

func set_player_location_to_last_rest():
	Data.sav.player_global_position = Data.sav.rest_locations[Data.sav.last_rested][0]

func enter_new_level():
	var spawn: Campfire = level_loader.current_level.spawn
	assert(spawn != null, "Level entering has no spawn, game will break")
	spawn.interact(false) # Does not perform a full rest animation
	set_player_location_to_last_rest() # Spawn is now set as last rest
	resting = true

func fast_travel(flag: String, index: int):
	Data.sav.current_level_index = index
	Data.sav.last_rested = flag
	
	await player.screen_effects.fade_to_black()
	
	reset_world_stats()
	set_player_location_to_last_rest()
	resting = true
	await load_level()
	await reload_player()

func create_loot(id: int, type: Data.LootType, pos: Vector3, flag: String):
	var loot_node: ItemLoot = loot_scene.instantiate()
	loot_node.type = type
	loot_node.id = id
	loot_node.flag = flag
	loot_node.global_position = pos
	level_loader.current_level.add_child(loot_node)
