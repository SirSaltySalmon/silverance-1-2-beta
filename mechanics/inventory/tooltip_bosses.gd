class_name TooltipBosses
extends VBoxContainer

@export var boss_thumbnail: TextureRect
@export var location_label: Label
@export var boss_desc_label: Label

const DEFAULT_THUMBNAIL_PATH = "res://assets/2d/boss_thumbnails/question_mark.jpg"
var def_texture: Texture

func _ready():
	def_texture = Methods.create_texture(DEFAULT_THUMBNAIL_PATH)

func update(index: int, is_defeated: bool):
	var location = Data.BOSSES[index][1]
	var desc = Data.BOSSES[index][2]
	
	location_label.text = location
	
	if is_defeated:
		boss_thumbnail.texture = Methods.create_texture(Data.BOSSES[index][3])
		boss_desc_label.text = desc
	else:
		boss_thumbnail.texture = def_texture
		boss_desc_label.text = "???"
