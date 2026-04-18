extends Area3D

@export var active := false

@export var parent: Character
@export var attack_separation := 0.5
@export var damage := 5

var counter := 0.0
var bodies : Array[Character] = []

func _on_body_entered(body: Node3D) -> void:
	if body is not Character:
		return
	if body == parent:
		return
	bodies.append(body)

func _process(delta: float) -> void:
	if not active:
		return
	counter += delta
	if counter >= attack_separation:
		counter = counter - attack_separation
		for chara in bodies:
			chara.receive_attack(damage, 1.0, parent)
		

func _on_body_exited(body: Node3D) -> void:
	bodies.erase(body)
