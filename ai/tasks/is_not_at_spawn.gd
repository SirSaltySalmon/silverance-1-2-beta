@tool
extends BTCondition
## IsNotAtSpawn condition checks if target is far enough away from the agent
## Returns [code]SUCCESS[/code] if target is out of range
## otherwise, returns [code]FAILURE[/code].

# Called to generate a display name for the task.
func _generate_name() -> String:
	return "Is not at spawn"

# Called when the task is executed.
func _tick(_delta: float) -> Status:
	if agent is BaseNPC:
		if agent.global_position.distance_squared_to(agent.spawnpoint) >= 0.5:
			return SUCCESS
	return FAILURE
