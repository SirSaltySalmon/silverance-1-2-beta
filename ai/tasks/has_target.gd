@tool
extends BTCondition
## HasTarget condition checks if the agent is has a valid Character for the variable target.
## Returns [code]SUCCESS[/code] if target exists
## otherwise, returns [code]FAILURE[/code].

# Called to generate a display name for the task.
func _generate_name() -> String:
	return "HasTarget"

# Called when the task is executed.
func _tick(_delta: float) -> Status:
	if agent is Character:
		if agent.target != null:
			return SUCCESS
		return FAILURE
	
	printerr("Not a Character, cannot get target variable")
	return FAILURE
