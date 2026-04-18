extends Interactable

@export var dialogue: DialogueResource
@export var dialogue_code: String

func interact():
	DialogueManager.show_dialogue_balloon(dialogue, dialogue_code)
