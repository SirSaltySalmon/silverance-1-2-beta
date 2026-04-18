extends Interactable

@export var anim: AnimationPlayer
@export var dialogue: DialogueResource

const FIRST_INTERACTION = "prisoner_first_talk"
const ADVICE = "prisoner_giving_advice"
const AFTER_ADVICE = "prisoner_after_advice"
const ENCOURAGE = "prisoner_encourage"
const CONGRATULATE = "prisoner_congratulate"

func _ready():
	anim.play("Sit_Floor_Idle")

func interact():
	if Data.sav.boss_flags["Dungeon Beast"]:
		DialogueManager.show_dialogue_balloon(dialogue, CONGRATULATE)
		return
	
	if not Data.sav.interact_flags[FIRST_INTERACTION]:
		DialogueManager.show_dialogue_balloon(dialogue, FIRST_INTERACTION)
		await DialogueManager.dialogue_ended
		Data.sav.interact_flags[FIRST_INTERACTION] = true
	elif Data.sav.death_counter >= 3 and not Data.sav.interact_flags[ADVICE]:
		DialogueManager.show_dialogue_balloon(dialogue, ADVICE)
		await DialogueManager.dialogue_ended
		Data.sav.interact_flags[ADVICE] = true
	elif Data.sav.interact_flags[ADVICE]:
		DialogueManager.show_dialogue_balloon(dialogue, AFTER_ADVICE)
	else:
		DialogueManager.show_dialogue_balloon(dialogue, ENCOURAGE)
