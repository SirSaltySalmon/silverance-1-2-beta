class_name SaveGame
extends Resource

@export var first_version_opened : String
@export var last_version_opened : String
@export var last_unix_time_saved : int

@export var death_counter := 0

@export var player_global_position := Vector3.ZERO
@export var player_rig_transform_basis: Basis
@export var max_health := 50
@export var health := 50
@export var max_heals := 2
@export var max_poise := 20
@export var poise := 20
@export var max_armour := 10
@export var armour := 10
@export var blood_meter := 0

@export var money := 0

@export var dead_id: Array[int]= []

@export var arsenal: Array[WeaponRes] = []
@export var equipped_active = -1
@export var equipped_sheathed = -1

@export var accessories: Array[AccessoryRes] = []
@export var equipped_acc: Array[int] = [-1, -1, -1]

@export var key_items: Array[KeyRes] = []

@export var loot_flags: Dictionary[String, bool] = {
	## Test area
	"dss": false,
	"crucifix": false,
	
	## First area
	"crucifix_prison": false,
	"blind_barb_sword": false,
	
	## Second area
	"dss_level_2": false,
}

@export var campfire_flags: Dictionary[String, bool] = {
	## Test area
	"Home": false,
	
	## Level 1
	"Flooded Cell": false,
	"Prison Exit": false,
	"Floating Platforms": false,
	
	## Level 2
	"Lair Entrance": false,
	"Lair of Harding": false,
}

@export var current_level_index := 1 #Because 0 is the test scene
@export var last_rested: String
@export var last_rested_rig_transform_basis: Basis
@export var rest_locations: Dictionary[String, Array] = {} #FORMAT: seat pos, level index, campfire pos

@export var interact_flags: Dictionary[String, bool] = {
	## Prisoner
	"prisoner_first_talk": false,
	"prisoner_giving_advice": false,
}

@export var boss_flags: Dictionary[String, bool] = {
	"Dungeon Beast": false, # Harding Demon
	"Test Boss": false, # Troughing Bull
}
