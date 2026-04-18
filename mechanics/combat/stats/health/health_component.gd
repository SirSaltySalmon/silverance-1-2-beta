class_name HealthComponent extends StatsBarComponent

@export var max_health := 100
@export var change_display: ChangeDisplayer

func _ready():
	max_value = max_health
	super()

func update_maxmin_values(max_v: int = max_value, min_v: int = min_value) -> void:
	super(max_v, min_v)
	change_display.max_value = max_v
	change_display.min_value = min_v
