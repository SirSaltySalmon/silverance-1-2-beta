extends StateMachine

@export var npc: BaseNPC

func transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	super(target_state_path, data)
