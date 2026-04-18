extends MenuPanel

@export var bosses_container: VBoxContainer
@export var tooltip_bosses: TooltipBosses
@export var button: PackedScene

func load_menu():
	tooltip_bosses.boss_thumbnail.texture = null
	tooltip_bosses.boss_desc_label.text = ""
	tooltip_bosses.location_label.text = ""
	
	for child in bosses_container.get_children():
		child.queue_free()
	for i in range(len(Data.BOSSES)):
		var boss_name = Data.BOSSES[i][0]
		var defeated = Data.sav.boss_flags[boss_name]
		var butt: BossButton = button.instantiate()
		butt.index = i
		butt.is_defeated = defeated
		butt.connect("selected", tooltip_bosses.update)
		if defeated:
			butt.text = boss_name
		else:
			butt.text = "???"
		bosses_container.add_child(butt)
