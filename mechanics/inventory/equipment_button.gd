class_name EquipmentButton
extends Button

signal selected(button: EquipmentButton)

var resource: Resource
var index: int

func _on_pressed() -> void:
	selected.emit(self)
