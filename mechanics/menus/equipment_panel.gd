class_name EquipmentPanel
extends MenuPanel

@export var button: PackedScene
@export var grid: GridContainer
@export var item_list_path: String
@export var tooltip: Tooltip

func load_menu():
	tooltip.reset()
	# When loading in, remove last instances
	for child in grid.get_children():
		child.queue_free()
	
	# Update by getting all weapons / accessories in inventory
	var item_list = Data.sav.get(item_list_path)
	for i in range(len(item_list)):
		var item = item_list[i]
		var new_item: EquipmentButton = button.instantiate()
		new_item.resource = item
		new_item.index = i
		new_item.icon = Methods.create_texture(item.thumbnail_path)
		new_item.connect("selected", tooltip.update)
		grid.add_child(new_item)
