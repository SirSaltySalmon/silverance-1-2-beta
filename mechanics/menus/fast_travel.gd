extends MenuPanel

@export var last_rested_label: Label
@export var level_list: VBoxContainer
@export var foldable: PackedScene
@export var button: PackedScene

func load_menu():
	last_rested_label.text = "Last Rested: " + Data.sav.last_rested
	
	for child in level_list.get_children():
		child.queue_free()
	
	var all_levels = []
	for level in Data.LEVELS:
		var level_container: CampfireFoldableContainer = foldable.instantiate()
		level_container.title = level[1] ## Name the container
		level_list.add_child(level_container)
		all_levels.append(level_container)
	
	for campfire_key in Data.sav.rest_locations:
		if Data.sav.campfire_flags[campfire_key]:
			var campfire_data = Data.sav.rest_locations[campfire_key]
			var level_index = campfire_data[1]
			var level_to_add_to: CampfireFoldableContainer = all_levels[level_index]
			var campfire_button: CampfireButton = button.instantiate()
			campfire_button.text = campfire_key
			campfire_button.level_index = level_index
			level_to_add_to.container.add_child(campfire_button)
			level_to_add_to.has_children = true
			campfire_button.selected.connect(Data.game.fast_travel)
	
	for level in all_levels:
		if not level.has_children:
			level.queue_free()
