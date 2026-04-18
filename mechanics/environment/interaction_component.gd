class_name InteractionComponent
extends Area3D

@export var parent: Interactable

@export var enabled = true

func _on_body_entered(body: Node3D) -> void:
	if body is Player:
		body.interactables.append(parent)

func _on_body_exited(body: Node3D) -> void:
	if body is Player:
		body.interactables.erase(parent)

func enable():
	enabled = true

func disable():
	enabled = false
