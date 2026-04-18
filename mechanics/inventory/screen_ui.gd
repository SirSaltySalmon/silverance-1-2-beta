extends BaseUI

func _ready() -> void:
	super()
	DialogueManager.connect("dialogue_ended", fade_in)
