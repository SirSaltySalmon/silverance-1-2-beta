class_name ItemLoot
extends Interactable

@export var texturerect: TextureRect
@export var id: int
@export var type: Data.LootType
@export var flag: String = ""

var resource: EquipmentRes

func _ready():
	if flag != "":
		if Data.sav.loot_flags[flag] == true:
			queue_free()
	if interaction_component:
		interaction_component.enable()
	else:
		printerr("No interaction component attached to this loot.")
	
	if not resource: # Resource could already have been set by game.create_loot()
		if type == Data.LootType.P_WEAPON:
			resource = Data.WEAPON[id]
		elif type == Data.LootType.P_ACCESSORY:
			resource = Data.ACCESSORY[id]
		elif type == Data.LootType.P_KEY:
			resource = Data.KEY[id]
		else:
			printerr("Loot is of undefined type.")
	
	if resource:
		texturerect.texture = Methods.create_texture(resource.thumbnail_path)
	else:
		printerr("This loot has no resource! Type: " + str(type) + " ID: " + str(id))
		queue_free()

func interact():
	interaction_component.disable()
	if type == Data.LootType.P_WEAPON:
		Data.sav.arsenal.append(resource)
	elif type == Data.LootType.P_ACCESSORY:
		Data.sav.accessories.append(resource)
	elif type == Data.LootType.P_KEY:
		Data.sav.key_items.append(resource)
	else:
		printerr("Loot is of undefined type.")
	if flag != "":
		Data.sav.loot_flags[flag] = true
	queue_free()
