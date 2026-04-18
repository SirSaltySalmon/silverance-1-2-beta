class_name InteractionAlert
extends RichTextLabel

func update(ptext: String):
	show()
	var first_event = InputMap.action_get_events("interact")[0]
	var input_name: String = InputEventHelper.get_text(first_event)
	text = "[%s] " %input_name + ptext
