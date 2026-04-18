class_name ScreenEffects
extends Control

var noun_verbed_queue = []
var queue_running = true

func _ready():
	SignalBus.noun_verbed.connect(_on_noun_verbed)
	show()

func fade_to_black():
	%ColorRect.show()
	var tween = create_tween()
	tween.tween_property(%ColorRect, "modulate", Color.BLACK, 0.5).from(Color(Color.BLACK, 0))
	await tween.finished
	return

func fade_to_clear():
	%ColorRect.show()
	var tween = create_tween()
	tween.tween_property(%ColorRect, "modulate", Color(Color.BLACK, 0), 0.5).from(Color.BLACK)
	await tween.finished
	%ColorRect.hide()
	return
	
func _on_noun_verbed(text, col):
	display_noun_verbed([text, col])
	# noun_verbed_queue.append([text, col])
	# queue_processor()

func queue_processor():
	if queue_running: return
	queue_running = true
	while not noun_verbed_queue.is_empty():
		noun_verbed_queue.pop_front()
		await display_noun_verbed(noun_verbed_queue.pop_front())
	queue_running = false

func display_noun_verbed(text_col_array):
	%NounVerbed.show()
	%NounVerbedLabel.modulate = text_col_array[1]
	%NounVerbedLabel.text = text_col_array[0]
	var tween = create_tween()
	tween.tween_property(%NounVerbed, "modulate", Color.WHITE, 1.0).from(Color(Color.WHITE, 0))
	await tween.finished
	await Methods.wait(2.0)
	tween = create_tween()
	tween.tween_property(%NounVerbed, "modulate", Color(Color.WHITE, 0), 1.0).from(Color.WHITE)
	await tween.finished
	%NounVerbed.hide()
	return
