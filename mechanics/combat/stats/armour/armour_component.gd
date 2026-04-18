class_name ArmourComponent extends StatsBarComponent	

@export var max_armour := 15
@export var regen_timer: Timer
@export var regen_cd := 3.0

func _ready():
	max_value = max_armour
	super()

func reset():
	value = max_value

func _on_damaged():
	reset_regen()
	if value <= 0:
		value = max_value

func reset_regen():
	regen_timer.start(regen_cd)

func _on_regen_timer_timeout() -> void:
	reset()
