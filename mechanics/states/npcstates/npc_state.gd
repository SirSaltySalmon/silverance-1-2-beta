class_name NPCState
extends State

var npc: BaseNPC

func _ready() -> void:
	await owner.ready
	npc = owner.npc as BaseNPC
	assert(npc != null, "Owner must be an NPC")

func apply_drag(target_speed: float, delta: float):
	var horizontal_velocity = Vector2(npc.velocity.x, npc.velocity.z)
	if horizontal_velocity.length() > target_speed:
		var current_speed = horizontal_velocity.length()
		if current_speed == 0.0:
			return ## Prevents dividing by zero
		var new_speed = max(current_speed - npc.accel * delta, target_speed)
		var speed_ratio = new_speed / current_speed
		npc.velocity.x *= speed_ratio
		npc.velocity.z *= speed_ratio

func apply_movement(target_velocity: Vector3, delta: float, accel: float, turn_speed: float) -> void:
	npc.velocity.x = move_toward(npc.velocity.x, target_velocity.x, delta * accel)
	npc.velocity.z = move_toward(npc.velocity.z, target_velocity.z, delta * accel)
	
	extra_rotation(target_velocity.normalized(), delta, turn_speed)

func extra_rotation(target_direction: Vector3, delta: float, turn_speed: float):
	var current_speed = npc.velocity.length()
	var current_direction = npc.velocity.normalized()
	var new_direction = current_direction.slerp(target_direction, delta * turn_speed)
	npc.velocity.x = new_direction.x * current_speed
	npc.velocity.z = new_direction.z * current_speed
