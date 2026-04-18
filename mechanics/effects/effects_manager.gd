extends Node3D
class_name EffectsManager

@export var parent: Character
@export var sprite: Sprite3D
@export var parry_vfx: PackedScene
@export var blockhit_vfx: PackedScene
@export var stagger_vfx: PackedScene
@export var bleed_vfx: PackedScene
@export var heal_vfx: PackedScene

func _ready():
	pass

func stun():
	sprite.modulate = Color.YELLOW
	animate()

func blockhit():
	spawn(blockhit_vfx)
	sprite.modulate = Color.SKY_BLUE
	animate()

func parry():
	spawn(parry_vfx)
	sprite.modulate = Color.GREEN
	animate()

func stagger():
	spawn(stagger_vfx)
	sprite.modulate = Color.RED
	animate()
	
func bleed():
	spawn(bleed_vfx)

func heal():
	spawn(heal_vfx)

func animate():
	%Anim.stop()
	%Anim.play("indicate")

func spawn(scene: PackedScene):
	var vfx = scene.instantiate()
	get_tree().root.add_child(vfx)
	vfx.global_position = parent.global_position
	vfx.global_position.y += 1
