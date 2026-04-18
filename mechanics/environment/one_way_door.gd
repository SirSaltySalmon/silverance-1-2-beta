extends Node3D

@export var anim: AnimationPlayer
@export var boss: BaseBoss

var disabled = false

func _ready():
	anim.play("open")
	SignalBus.connect("boss_arena_entered", close_door)

func close_door(pboss: BaseBoss) -> void:
	if disabled:
		return
	if not is_instance_valid(boss):
		return
	if boss != pboss:
		return
	anim.play("close")
	boss.connect("died", boss_defeated)
	disabled = true

func boss_defeated():
	anim.play("open")
