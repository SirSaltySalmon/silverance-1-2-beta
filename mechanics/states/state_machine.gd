## State machine that handles swapping between state and calling a state when it is active
class_name StateMachine extends Node

## Select initial state from menu
@export var initial_state: State = null
## Calls a lambda function to get the initial state, or get the first children if not set
@onready var state: State = (
	func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
	).call()

func _ready():
	## Get every state node that is a child of this machine
	for each_state: State in find_children("*", "State"):
		## Connect the signal to the function that handles the swap
		each_state.next_state.connect(transition_to_next_state)
	
	## The owner is the root node of the scene, which is the player character. Wait for ready
	## to guarantee that we have all the data needed.
	await owner.ready
	state.enter(state)

func transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return
	if state.name == "Death":
		printerr(owner.name + ": Trying to transition to another state when dead")
		return

	## Call exit of previous state, get new state from path, then call enter of new state
	var previous_state := state
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state, data)

func _process(delta: float) -> void:
	state.update(delta)

func _physics_process(delta: float) -> void:
	state.physics_update(delta)
