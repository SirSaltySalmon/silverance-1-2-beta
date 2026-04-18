@tool
extends BTCondition
## AboveDistance condition checks if target is far enough away from the agent
## Returns [code]SUCCESS[/code] if target is out of range
## otherwise, returns [code]FAILURE[/code].

## Minimum distance to target.
@export var distance_min: float

## Blackboard variable that holds the target (expecting Node2D).
@export var target_var: StringName = &"target"

var _min_distance_squared: float


# Called to generate a display name for the task.
func _generate_name() -> String:
	return "At least (%d) away from %s" % [distance_min,
		LimboUtility.decorate_var(target_var)]


# Called to initialize the task.
func _setup() -> void:
	## Small performance optimization
	_min_distance_squared = distance_min * distance_min


# Called when the task is executed.
func _tick(_delta: float) -> Status:
	if not is_instance_valid(agent.target):
		return FAILURE

	var dist_sq: float = agent.global_position.distance_squared_to(agent.target.global_position)
	if dist_sq >= _min_distance_squared:
		return SUCCESS
	else:
		return FAILURE
