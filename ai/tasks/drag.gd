@tool
extends BTAction
## Apply drag on player. Always return SUCCESS

# Display a customized name (requires @tool).
func _generate_name() -> String:
	return "Apply drag"

# Called each time this task is entered.
func _enter() -> void:
	assert(agent is Character, "Agent is not a Character")

# Called each time this task is ticked (aka executed).
func _tick(delta: float) -> Status:
	apply_drag(0, delta)
	return SUCCESS


func apply_drag(target_speed: float, delta: float):
	if agent.velocity.length() > target_speed:
		var horizontal_velocity = Vector2(agent.velocity.x, agent.velocity.z)
		var current_speed = horizontal_velocity.length()
		if current_speed == 0.0:
			return ## Prevents dividing by zero
		var new_speed = max(current_speed - agent.accel * delta, target_speed)
		var speed_ratio = new_speed / current_speed
		agent.velocity.x *= speed_ratio
		agent.velocity.z *= speed_ratio
