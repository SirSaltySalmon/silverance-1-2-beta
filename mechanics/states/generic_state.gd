## Parent class for all states
class_name State extends Node

## Emitted when the class should move on to the next state. May also send additional data if needed.
signal next_state(next_state_path: String, data: Dictionary)

## Called every loop tick (once per frame, speed dependent on frame rate)
func update(_delta: float) -> void:
	pass

## Called every physics tick (60fps)
func physics_update(_delta: float) -> void:
	pass

## Called when state is entered. Passed data can help initialize the state.
## Contains an empty data dictionary if no data is passed.
func enter(_previous_state: State, _data := {}) -> void:
	pass

## Called before moving to the next state for clean up.
func exit() -> void:
	pass
