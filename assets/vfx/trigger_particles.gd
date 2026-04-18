class_name TriggerParticles
extends Node3D

@export var autoplay := true
@export var anim: AnimationPlayer

func _ready():
	if not autoplay:
		return
	play()

func play():
	anim.play("play")
	await anim.animation_finished
	if autoplay:
		queue_free()
