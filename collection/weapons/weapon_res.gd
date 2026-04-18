class_name WeaponRes
extends EquipmentRes

@export var path: Array[String]

func _init(p_display_name: String = "Null", p_description: String = "Null", p_path: Array[String] = ["Null"], p_thumbnail_path: String = "Null"):
	display_name = p_display_name
	description = p_description
	path = p_path
	thumbnail_path = p_thumbnail_path
