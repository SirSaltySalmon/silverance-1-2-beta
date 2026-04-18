extends Area3D

@export var parent: Character

const AUDIBLE_STATES = ["Run", "Dodge", "Attack", "BlockHit", "Parry"]

var bodies: Array[Character]

func _on_body_entered(body: Node3D) -> void:
	if not body is Character:
		return
	if body.is_on_same_team_as(parent):
		return
	bodies.append(body)

func _on_body_exited(body: Node3D) -> void:
	if not body is Character:
		return
	bodies.erase(body)

func _physics_process(_delta: float) -> void:
	if parent.dead:
		return
	if parent.target:
		return
	if not bodies:
		return
	for chara in bodies:
		if chara.state_machine.state.name in AUDIBLE_STATES:
			parent.target = chara
