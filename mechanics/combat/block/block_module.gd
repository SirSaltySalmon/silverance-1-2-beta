class_name BlockComponent extends Node

@export var chara: Character
@export var parry_timer: Timer
@export var punish_timer: Timer
@export var player_buffer: Timer
@export var blocking := false
@export var parry := false

var punish := 0

func _ready():
	set_process(true)

func _process(_delta):
	if chara.block_condition():
		if not blocking:
			enable_blocking()
	elif blocking:
		disable_blocking()

func enable_blocking(should_parry := true) -> void:
	chara.block_animation_enable()
	blocking = true
	## Blocking without parry will negate 50% of health & 100% armour damage, but will take normal poise damage still.
	chara.add_multiplier("Block", "res", 0.5, "Health")
	chara.add_multiplier("Block", "res", 1.0, "Armour")
	if should_parry:
		enter_parry()

func disable_blocking() -> void:
	chara.block_animation_disable()
	blocking = false
	chara.remove_multiplier("Block", "res")
	exit_parry()

func enter_parry() -> void:
	if chara is Player:
		if not punish_timer.is_stopped():
			punish = min(punish + 1, 4)
		var punish_time = chara.parry_time * (punish / 4.0)
		if punish_time < chara.parry_time:
			parry_timer.start(chara.parry_time - punish_time)
		punish_timer.start(chara.parry_time * 2.0)
	parry = true

func _on_punish_timer_timeout() -> void:
	reset_punish()

func on_successful_parry():
	## Effects handled by state change
	reset_punish()
	enter_parry()

func reset_punish() -> void:
	punish = 0

func exit_parry():
	parry = false
	parry_timer.stop()

func can_block():
	return blocking

func can_parry():
	var is_player = chara is Player
	var always_parry = Config.get_config("InputSettings", "AlwaysParry", false) if is_player else false
	return (always_parry and can_block()) or (
			parry and ((is_player and not parry_timer.is_stopped()) or 
			not is_player)
			)
