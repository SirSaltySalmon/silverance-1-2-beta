class_name Campfire
extends Interactable

@export var flag: String
@export var spawnpoint := false
@export var fire_vfx: ActivateParticles
var activated := false

func _ready() -> void:
	if not flag in Data.sav.campfire_flags.keys():
		return printerr("Flag for this campfire is invalid! " + str(self))
	
	var level: BaseLevel = get_parent()
	assert(level != null, "Level not fetched for campfire with flag " + flag)
	
	if spawnpoint:
		level.spawn = self
	
	activated = Data.sav.campfire_flags[flag]
	Data.sav.rest_locations[flag] = [get_seat_pos(), Data.sav.current_level_index, global_position]
	
	if activated:
		play_effects()

func get_seat_pos():
	return %Seat.global_position

func play_effects():
	fire_vfx.play()
	
func interact(perform_full_rest := true):
	Data.sav.last_rested = flag
	
	if not activated:
		Data.sav.campfire_flags[flag] = true
		_ready()
		if perform_full_rest:
			Data.new_campfire_lit = true
	
	if perform_full_rest:
		SignalBus.rest_prepare.emit()
