extends Label

func _process(delta: float) -> void:
	if Config.get_config("InputSettings", "ShowControlsOnScreen", true):
		show()
	else: 
		hide()
