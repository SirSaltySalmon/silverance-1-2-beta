class_name LastGroundLocation
extends Node3D

@export var char: Character

func _physics_process(delta: float) -> void:
	if char.is_on_floor():
		global_position = char.global_position
