class_name BloodMeterComponent
extends Sprite3D

@export var parent: Character
@export var bars: Array[ProgressBar]

@onready var unfilled_theme = preload("res://assets/ui_themes/bloodmeter.tres")
@onready var filled_theme = preload("res://assets/ui_themes/bloodmeter_full.tres")

func _ready():
	SignalBus.attack_received.connect(calculate_blood_update)

func calculate_blood_update(dmg: int, victim: Character, attacker: Character):
	if victim == parent or attacker == parent:
		gain(dmg) # Blood gain is on base damage applied before multipliers

func _process(delta: float):
	update_texture()

func update_texture():
	for bar in bars:
		if bar.value == bar.max_value:
			bar.theme = filled_theme
		else:
			bar.theme = unfilled_theme

func gain(amount: int):
	var i := 0
	while amount > 0 and i < bars.size():
		var bar = bars[i]
		if bar.value != bar.max_value: # bar must not be full already
			var diff = bar.max_value - bar.value
			if diff <= amount: # can't put all in this bar, deduct for next bar
				amount -= diff
				bar.value += diff
			else:  # diff > amount — bar can absorb the rest
				bar.value += amount
				amount = 0
		i += 1

func lose(amount: int):
	var i := bars.size() - 1
	
	while amount > 0:
		var bar = bars[i]
		if bar.value > amount:
			bar.value -= amount
			amount = 0
		else:
			amount -= bar.value
			bar.value = 0
		i -= 1
		
		if i == -1 and amount != 0:
			printerr("Still has blood loss left to deduct: " + str(amount))
			amount = 0

func deduct_if_possible(amount: int):
	if amount <= get_value():
		lose(amount)
		return true
	return false

func get_value() -> int:
	var total := 0
	for bar in bars:
		total += bar.value
	return total

func set_value(amount: int):
	for bar in bars:
		bar.value = 0
	gain(amount)
