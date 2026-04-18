extends Special

@export var state: PlayerGroundState
@export var timer: Timer
@export var duration := 1.2

func trigger():
	SignalBus.shake_camera.emit()
	state.player = player
	state.reparent(player.state_machine) # Will reparent back to weapon once finished (in state code)
	player.state_machine.transition_to_next_state(state.name)
	timer.start(duration)

func _on_timer_timeout() -> void:
	player.state_machine.transition_to_next_state("Idle")
