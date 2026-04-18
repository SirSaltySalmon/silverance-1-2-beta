class_name Multiplier extends Node

var character: Character
var value : float
var type: String #Either General, Health, Poise, or Armour
var duration: float
var timer : Timer = null

func _init(pcharacter: Character, pname: String, pvalue: float, ptype := "General", pduration := -1):
	character = pcharacter
	name = pname
	value = pvalue
	type = ptype
	duration = pduration
	
	if duration > 0:
		timer = Timer.new()
		timer.connect("timeout", _on_duration_over)
		timer.one_shot = true
		pcharacter.add_child(timer)
		timer.start(duration)

func get_remaining_duration():
	return timer.time_left

func _on_duration_over():
	character.remove_multiplier_by_ref(self)
