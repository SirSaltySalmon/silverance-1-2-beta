extends Interactable

@export var to_id: int

func interact():
	await Data.game.player.screen_effects.fade_to_black()
	Data.game.enter_new_location(to_id)
