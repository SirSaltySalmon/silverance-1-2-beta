extends Control

func _on_ResetGameControl_reset_confirmed() -> void:
	Data.reset()
	Data.game.enter_new_location(Data.sav.current_level_index)
