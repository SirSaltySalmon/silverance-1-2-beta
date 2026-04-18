extends Tooltip

func _on_equip_1_pressed() -> void:
	remove_dupes(index)
	Data.sav.equipped_acc[0] = index
	player.update_accessory_equipment()

func _on_equip_2_pressed() -> void:
	remove_dupes(index)
	Data.sav.equipped_acc[1] = index
	player.update_accessory_equipment()

func _on_equip_3_pressed() -> void:
	remove_dupes(index)
	Data.sav.equipped_acc[2] = index
	player.update_accessory_equipment()

func remove_dupes(index: int):
	for i in range(len(Data.sav.equipped_acc)):
		if Data.sav.equipped_acc[i] == index:
			Data.sav.equipped_acc[i] = -1
