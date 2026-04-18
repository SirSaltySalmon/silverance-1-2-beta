class_name CampfireButton
extends Button

signal selected(flag: String, i: int)

var level_index: int

func _on_pressed() -> void:
	selected.emit(text, level_index)
