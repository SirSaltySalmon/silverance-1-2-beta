class_name AccessoryDisplay
extends Control

@export var player: Player
var loaded_texture: Array[CompressedTexture2D] = [null, null, null]

func _ready():
	player.connect("accessory_changed", update_display)
	pass

func update_display(res_arr: Array[AccessoryRes]):
	loaded_texture = [null, null, null]
	for i in len(res_arr):
		if res_arr[i]:
			loaded_texture[i] = Methods.create_texture(res_arr[i].thumbnail_path )
	update_icon()

func update_icon():
	%Equipped1.texture = loaded_texture[0]
	%Equipped2.texture = loaded_texture[1]
	%Equipped3.texture = loaded_texture[2]
