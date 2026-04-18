class_name BaseLevel
extends Node3D

@export var id := 0

var spawn: Campfire

func _ready():
	Data.current_level_index = id
