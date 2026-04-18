class_name WeaponDisplay
extends BaseUI

@export var player: Player
@export var equipped: TextureRect
@export var sheathed: TextureRect
@export var special_displayer: Label
var loaded_texture: Array[CompressedTexture2D] = [null, null]

func _ready():
	player.connect("loadout_changed", update_display)
	player.connect("weapon_switched", swap_icons)
	player.connect("weapon_equipped", update_special_display)
	pass

func update_display(main_res: WeaponRes, sheathed_res: WeaponRes):
	loaded_texture[0] = Methods.create_texture(main_res.thumbnail_path) if main_res else null
	loaded_texture[1] = Methods.create_texture(sheathed_res.thumbnail_path) if sheathed_res else null
	update_icon()

func update_icon():
	equipped.texture = loaded_texture[0]
	sheathed.texture = loaded_texture[1]

func swap_icons():
	loaded_texture.reverse()
	update_icon()

func update_special_display(weapon_nodes: Array[Weapon]):
	special_displayer.text = ""
	if not weapon_nodes:
		return
	var special = weapon_nodes[0].special_node
	if not special:
		return
	special_displayer.text = special.special_name + " (%s)" %special.cost
