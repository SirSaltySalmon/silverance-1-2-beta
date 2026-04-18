extends Sprite3D
class_name EffectManager

@onready var timer = $Timer

func _ready():
	hide()

func display(color: Color, time := -1.0):
	timer.stop()
	modulate = color
	show()
	if time == -1.0:
		return
	timer.start(time)

func _on_timer_timeout() -> void:
	hide()

func stun():
	display(Color.YELLOW, 0.2)

func blockhit():
	display(Color.AQUA, 0.2)

func parry():
	display(Color.GREEN, 0.2)

func stagger():
	display(Color.RED, 0.5)
