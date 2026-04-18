extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body is Character:
		body.damaging_fall_behavior()
