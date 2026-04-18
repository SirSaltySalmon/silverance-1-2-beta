extends Node

var sav: SaveGame = null

const SAVE_STATE_PATH := "user://SILVERANCE_SAVE.tres"
const NO_VERSION_NAME = "0.0.0"

var has_save := false

signal preparing_to_save ## Useful to make any object provide information before saving

var player: Player
var scene_tree: SceneTree
var game: AbstractGameScene

var autosave_active = true
var autosave_time := 5.0
var autosave_remaining := autosave_time

var npc_id_counter = 0
var current_level_index = 0
var current_level_spawnpoint: Campfire

var new_campfire_lit := false

func _ready():
	has_save = true if _load_current_save() else false

func clear_dead_id():
	sav.dead_id = []

func open():
	_log_version()
	save()

func get_current_ver() -> String:
	return ProjectSettings.get_setting("application/config/version", NO_VERSION_NAME)

func reset() -> void:
	npc_id_counter = 0
	sav = SaveGame.new()

func _log_time() -> void:
	if sav != null:
		sav.last_unix_time_saved = int(Time.get_unix_time_from_system())

func _log_version() -> void:
	if sav != null:
		var current_version = get_current_ver()
		if current_version.is_empty():
			current_version = NO_VERSION_NAME
		if not sav.first_version_opened:
			sav.first_version_opened = current_version
		sav.last_version_opened = current_version

func _load_current_save() -> bool:
	npc_id_counter = 0
	if FileAccess.file_exists(SAVE_STATE_PATH):
		sav = ResourceLoader.load(SAVE_STATE_PATH, "", ResourceLoader.CACHE_MODE_IGNORE)
	if not sav:
		print("No save game exists. Loading new game instead")
		sav = SaveGame.new()
		return false
	return true

func save() -> void:
	_log_time()
	if sav != null:
		preparing_to_save.emit()
		ResourceSaver.save(sav, SAVE_STATE_PATH)
	else:
		printerr("Attempting to save when no save file is present")

func _process(delta):
	# Handle autosave
	if not autosave_active:
		return
	if not player:
		return
	if not is_instance_valid(player):
		return
	if player.dead:
		return
	if not scene_tree:
		scene_tree = get_tree()
	if not is_instance_valid(scene_tree):
		scene_tree = get_tree()
	if scene_tree.paused:
		return
	
	if player.is_in_combat():
		autosave_remaining = 0
		return
	
	if autosave_remaining >= 0 or player.is_on_floor():
		autosave_remaining -= delta
	
	if autosave_remaining <= 0 and player.is_on_floor():
		autosave_remaining = autosave_time + autosave_remaining
		print("Saving")
		save()
	
	## TODO: Save automatically when resting 

enum LootType {NULL, P_WEAPON, P_ACCESSORY, P_KEY}

#region Weapons
var WEAPON = [
	WeaponRes.new(
		"Greatsword",
		"It was too small to be called a heap of raw iron. Bigger than average, slim, wieldy, and far too smooth. Indeed, it was a sword.",
		["res://collection/weapons/greatsword/greatsword.tscn"],
		"res://collection/weapons/greatsword/greatsword.png"),
	WeaponRes.new(
		"Dual Straight Swords",
		"A versatile pair of straight swords made for mobility and outmaneuvering opponents.",
		["res://collection/weapons/dual_straight_swords/dss_1.tscn", "res://collection/weapons/dual_straight_swords/dss_2.tscn"],
		"res://collection/weapons/dual_straight_swords/dual_straight_swords.png")
]

const WEAPON_SFX_MAP = {
	"1H": "res://sound/sfx/woosh_1H.mp3",
	"2H": "res://sound/sfx/whoosh-wind.mp3",
	"DW": "res://sound/sfx/light_woosh.mp3"
}
#endregion

#region Accessories
var ACCESSORY = [
	AccessoryRes.new(
		"Crucifix",
		"Its holiness forms a strange protective aura. Reduces damage taken to poise by 20%.",
		"res://collection/accessories/crucifix/crucifix.tscn",
		"res://collection/accessories/crucifix/crucifix.png")
]
#endregion

#region Key Items
var KEY = []
#endregion

#region Bosses
var BOSSES = [
	["Dungeon Beast", "Dungeon", "A mindless monster stationed to guard the Dungeon from a time history does not remember. Even now when barbarians have taken over the prison, it cares not for the authority it serves. It's only purpose is to make an example out of escapees.", "res://assets/2d/boss_thumbnails/question_mark2.jpg"],
	["Test Boss", "Test Area", "This boss is just a test for the Quest Log system!", "res://assets/2d/boss_thumbnails/question_mark2.jpg"],
]
#endregion

#region Levels
var LEVELS = [
	["res://levels/test.tscn", "Test Area"],
	["res://levels/level_1.tscn", "Dungeon"],
	["res://levels/level_2.tscn", "Harding's Lair"]
]
