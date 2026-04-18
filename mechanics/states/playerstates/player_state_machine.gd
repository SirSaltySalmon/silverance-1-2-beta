class_name PlayerStateMachine extends StateMachine

@export var player: Player

var input_disabled := false

func _ready():
	if player.game.resting:
		state = get_node("Rest")
	await super()
	DialogueManager.connect("dialogue_started", disable_input)
	DialogueManager.connect("dialogue_ended", enable_input)

func transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	super(target_state_path, data)
	## Enter the right group of animations on the state machine. Specific animations are
	## then handled separately in the code of each state
	# ...other code to handle air hit, stun and knock down state etc.
	## NOTE: As of 31/10/2025 this code is actually an artifact of giving previous state paths
	## instead of the whole previous state, so can't check for type IN the state, would be nice
	## to refactor this into the state's code and cleanup, but for now it's not broken.
	if state is PlayerGroundState:
		if state.name in ["Hit", "BlockHit", "Stagger"]:
			player.anim_sm.travel("DamagedStates")
			return
		if state.name in ["KnockDown", "Death"]:
			player.anim_sm.travel("KnockDown")
			return
		player.anim_sm.travel("GroundStates")
		return
	if state is PlayerAirState:
		if state.name == "AirHit":
			player.anim_sm.travel("AirHit")
			return
		player.anim_sm.travel("AirStates")
		return

func disable_input(arbitrary):
	input_disabled = true

func enable_input(arbitrary):
	input_disabled = false

func _unhandled_input(event: InputEvent) -> void:
	if input_disabled:
		return
	state.handle_input(event)
