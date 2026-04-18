extends VBoxContainer

@export var parent: Character

@onready var res_mults = $ResMults
@onready var dmg_mults = $DmgMults

var res_duration_tracked = []
var dmg_duration_tracked = []

func _ready():
	parent.connect("mult_updated", _on_mult_updated)
	_on_mult_updated("res")
	_on_mult_updated("dmg")

func _on_mult_updated(type := "both"):
	var arr: Array[Multiplier]
	if type in ["res", "both"]:
		arr = parent.resistance_mults
		res_duration_tracked.clear()
		display_mults(arr, res_mults, true)
	if type in ["dmg", "both"]:
		arr = parent.damage_mults
		dmg_duration_tracked.clear()
		display_mults(arr, dmg_mults, false)

func display_mults(arr: Array[Multiplier], displayer: Control, is_res: bool):
	var children = displayer.get_children()
	for child in children:
		child.queue_free()
	for mult in arr:
		var display = Label.new()
		display.text = mult.name + ", " + mult.type + ", " + str(mult.value)
		display.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		if mult.duration != -1:
			if is_res:
				res_duration_tracked.append([display, mult, display.text])
			else:
				dmg_duration_tracked.append([display, mult, display.text])
		displayer.add_child(display)

func _process(delta: float) -> void:
	if res_duration_tracked:
		update_time(res_duration_tracked)
	if dmg_duration_tracked:
		update_time(dmg_duration_tracked)

func update_time(duration_trackeds):
	for mult_combo in duration_trackeds:
		var mult_node = mult_combo[1]
		if not mult_node:
			return
		var time_left = snapped(mult_node.timer.time_left, 0.01)
		mult_combo[0].text = mult_combo[2] + " " + str(time_left)
