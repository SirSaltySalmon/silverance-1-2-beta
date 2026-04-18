class_name Tooltip
extends ScrollContainer

@export var texturerect: TextureRect
@export var name_label: Label
@export var desc_label: Label
var index: int
@export var equip_buttons: VBoxContainer
@export var player: Player


func reset():
	name_label.text = "Select An Item"
	desc_label.text = ""
	texturerect.texture = null
	index = -1
	equip_buttons.hide()

func update(button: EquipmentButton):
	var res = button.resource
	if res is EquipmentRes:
		name_label.text = res.display_name
		desc_label.text = res.description
		texturerect.texture = button.icon
		index = button.index
		equip_buttons.show()
