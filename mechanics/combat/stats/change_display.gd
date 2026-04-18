class_name ChangeDisplayer extends ProgressBar

@export var bar: ProgressBar
@export var time_until_animation := 2.0
@export var animation_duration := 1.0
@export var timer: Timer
@onready var target_value : float
@onready var counter := 0.0

func _ready():
	await bar.ready
	value = bar.value
	max_value = bar.max_value
	min_value = bar.min_value
	target_value = bar.value
	bar.connect("value_changed", _on_bar_value_changed)
	timer.connect("timeout", _on_timer_timeout)

func _on_bar_value_changed(new_val: int) -> void:
	# No animation played when health is gained or does not change, only updates value
	if new_val >= target_value or new_val >= value:
		value = new_val
		target_value = new_val
		return
	# if health is lost, start counting down
	if new_val < value:
		target_value = new_val
		timer.start(time_until_animation)

func _on_timer_timeout() -> void:
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "value", target_value, animation_duration)
