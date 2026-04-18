extends VBoxContainer

@export var bars: Array[ProgressBar]

@onready var unfilled_theme = preload("res://assets/ui_themes/bloodmeter.tres")
@onready var filled_theme = preload("res://assets/ui_themes/bloodmeter_full.tres")

func _process(_delta: float):
	update_texture()

func update_texture():
	for bar in bars:
		if bar.value == bar.max_value:
			bar.theme = filled_theme
		else:
			bar.theme = unfilled_theme

func gain(amount: int):
	var values_to_add = []
	
	var i := 0
	while amount > 0:
		var bar = bars[i]
		if bar.value == bar.max_value:
			values_to_add.append(0)
		else:
			var diff = bar.max_value - bar.value
			if diff <= amount:
				values_to_add.append(diff)
				amount -= diff
			else: #diff > amount:
				values_to_add.append(amount)
				amount = 0
		i += 1
	
	for j in range(values_to_add.size()):
		bars[j].value += values_to_add[j]

func lose(amount: int):
	var i := bars.size()
	
	while amount > 0:
		var bar = bars[i]
		if bar.value > amount:
			bar.value -= amount
			amount = 0
		else:
			amount -= bar.value
			bar.value = 0
		i -= 1
		
		if i == 0 and amount != 0:
			printerr("Still has blood loss left to deduct: " + str(amount))
			amount = 0

func deduct(amount: int):
	if amount >= get_value():
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
