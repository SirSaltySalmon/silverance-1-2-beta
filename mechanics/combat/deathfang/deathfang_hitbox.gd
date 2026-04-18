extends Area3D
class_name DeathfangHitbox

@export var parent: Player
@export var deathfang_indicator: Sprite3D

var active = true

var targets: Array[Character] = []
var targets_deathfangable: Array[Character] = []
var prioritized_deathfang: BaseNPC

func _ready():
	targets.clear()

func _physics_process(_delta: float) -> void:
	if not active:
		deathfang_indicator.reparent(self)
		deathfang_indicator.hide()
		return
	
	targets_deathfangable = targets.filter(_is_deathfangable)
	
	## If locked on to a target, even if there are Deathfangable targets in the vicinity,
	## will not perform Deathfang on them unless they are the locked on target.
	if parent.target:
		if parent.target in targets_deathfangable:
			prioritized_deathfang = parent.target
		else:
			prioritized_deathfang = null
	elif targets_deathfangable:
		prioritized_deathfang = Methods.get_closest(parent, targets_deathfangable)
	else:
		prioritized_deathfang = null
	
	if prioritized_deathfang:
		deathfang_indicator.reparent(prioritized_deathfang)
		deathfang_indicator.show()
		if prioritized_deathfang.custom_target_indicator_pos:
			deathfang_indicator.position = prioritized_deathfang.custom_target_indicator_pos
		else:
			deathfang_indicator.position = Vector3(0, 1.2, 0)
	else:
		deathfang_indicator.reparent(self)
		deathfang_indicator.hide()

func _on_body_entered(body: Node3D) -> void:
	if body is not Character:
		return
	if body == parent:
		return
	targets.append(body)

func _on_body_exited(body: Node3D) -> void:
	if body is not Character:
		return
	if body == parent:
		return
	targets.erase(body)

func can_deathfang():
	## If locked on to a target, even if there are Deathfangable targets in the vicinity,
	## will not perform Deathfang on them.
	return prioritized_deathfang != null and not parent.dead

func _is_deathfangable(chara: BaseNPC):
	return (chara.is_staggered or not chara.engaged) and not chara.dead

func disable():
	active = false
	prioritized_deathfang = null
	deathfang_indicator.hide()
	targets.clear()
	targets_deathfangable.clear()

func enable():
	active = true
