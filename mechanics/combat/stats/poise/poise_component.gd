class_name PoiseComponent extends StatsBarComponent

@export var max_poise := 50
@export var change_display: ChangeDisplayer
@export var regen_timer: Timer
@export var regen_cd := 1.0
@export var regen_multiplier := 1.0

var can_regen := false

var health: HealthComponent

func _ready():
	max_value = max_poise
	super()
	health = parent.health
	# Hristina hates men
	# Anja also hates men

func update_maxmin_values(max_v: int = max_value, min_v: int = min_value) -> void:
	super(max_v, min_v)
	change_display.max_value = max_v
	change_display.min_value = min_v

func update_regen_cd(time: float):
	regen_cd = time

func _on_damaged() -> void:
	reset_regen()

func reset_regen():
	can_regen = false
	regen_timer.start(regen_cd)

func pause_regen():
	can_regen = false
	regen_timer.stop()

func resume_regen():
	_on_regen_timer_timeout()

func heal_deathfang():
	value += (max_value/5)

func _on_regen_timer_timeout() -> void:
	can_regen = true

## Restore less posture per second if have lower health, 0.25 to 1.0
func get_health_factor():
	var health_ratio = health.value / health.max_value
	return 0.25 + (health_ratio * 0.75)

func _process(delta: float) -> void:
	if can_regen and parent.health.value != 0:
		value += delta * regen_multiplier * 5.0 * get_health_factor()
