extends Tooltip

func _on_equip_main_pressed() -> void:
	Data.sav.equipped_active = index
	if Data.sav.equipped_sheathed == index:
		Data.sav.equipped_sheathed = -1
	player.update_weapon_equipment()
	grab_focus()
	release_focus()

func _on_equip_sheathed_pressed() -> void:
	Data.sav.equipped_sheathed = index
	if Data.sav.equipped_active == index:
		Data.sav.equipped_active = -1
	player.update_weapon_equipment()
