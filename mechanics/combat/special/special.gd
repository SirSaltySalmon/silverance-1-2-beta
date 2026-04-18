extends Node
class_name Special

@export var player: Character
@export var special_name: String
@export var cost: int
@export var effects: Node3D

func try_trigger():
	if player.blood:
		if player.blood.deduct_if_possible(cost):
			trigger()

func trigger():
	pass

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	pass
