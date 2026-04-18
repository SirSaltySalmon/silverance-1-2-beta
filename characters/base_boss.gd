class_name BaseBoss
extends BaseNPC

@export var flag: String
@export var arena: Area3D
@export var collider: CollisionShape3D # Bosses will often be big, need to animate colliders for accuracy

var to_detach_from: BossBarsDisplayer

func _ready():
	if Data.sav.boss_flags[flag]:
		# Is defeated
		queue_free()
		return
	super()
	arena.connect("body_entered", _on_body_enters_arena)
	arena.connect("body_exited", _on_body_exits_arena)

func _on_body_enters_arena(body):
	if body is Player:
		target = body
		to_detach_from = body.boss_bars.attach(self)
		SignalBus.boss_arena_entered.emit(self)

func _on_body_exits_arena(body):
	if body == target:
		target = null
		body.boss_bars.detach(self)

# What happens if multiple enemy against 1 boss?
# Like if we allow for summoning an NPC to fight.
# Develop a proper targetting system for ALL NPCs if time allows

func stagger():
	super()
	anim_player.play("RESET")

func blockhit():
	super()
	anim_player.play("RESET")

func parry():
	super()
	anim_player.play("RESET")

func stun():
	super()
	anim_player.play("RESET")
