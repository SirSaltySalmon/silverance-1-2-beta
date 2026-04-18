extends PanelContainer

@export var player: Player
@export var label: Label

func _process(_delta: float) -> void:
	label.text = "Heals Left: " + str(player.heals_left)
