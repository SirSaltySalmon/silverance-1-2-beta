extends Area3D

@export var parent: Character
@export var team: Character.Teams

func _on_body_entered(body: Node3D) -> void:
	if parent.dead:
		return
	if parent.target:
		return
	if not body is Character:
		return
	if body.is_on_same_team_as(parent):
		return
	if body.is_on_team(team):
		parent.target = body
