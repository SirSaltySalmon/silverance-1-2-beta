class_name BossButton
extends Button

signal selected(i: int, is_def: bool)

var index: int
var is_defeated: bool

func _on_pressed() -> void:
	selected.emit(index, is_defeated)
