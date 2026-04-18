extends Node3D

@export var sfx: AudioStreamPlayer3D
@export var fire_vfx: ActivateParticles
@export var explosion: TriggerParticles
@export var anim: AnimationPlayer

func play_explosion():
	explosion.play()
	sfx.play()

func play_effects():
	fire_vfx.play()
	anim.play("play")

func kill():
	fire_vfx.stop()
	anim.stop()
	await Methods.wait(10.0)
	queue_free()
