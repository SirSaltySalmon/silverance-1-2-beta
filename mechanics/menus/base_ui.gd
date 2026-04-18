class_name BaseUI
extends Control

func _ready() -> void:
	DialogueManager.connect("dialogue_started", fade_out)

func fade_out(arbitrary = false):
	# It's actually more intuitive to just not fade
	# var tween = create_tween()
	# tween.tween_property(self, "modulate", Color(Color.WHITE, 0), 0.5).from(Color.WHITE)
	# await tween.finished
	hide()

func fade_in(arbitrary = false):
	show()
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.5).from(Color(Color.WHITE, 0))
