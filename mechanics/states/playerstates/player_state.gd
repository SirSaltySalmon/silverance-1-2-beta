class_name PlayerState extends State

## Helper variables to differentiate holding and pressing a button
var hold_counter : float = 0.0

var player: Player

## Only player states receives input because only PlayerStateMachine handle inputs
func handle_input(_event: InputEvent):
	pass

## Helper function to check if an input is held
## Put in the update method to get delta
func check_for_hold(input_name: String, delta: float, hold_time := 0.3):
	if Input.is_action_pressed(input_name):
		hold_counter += delta
		if hold_counter >= hold_time:
			hold_counter = hold_time
			return true
		return false
	else:
		reset_hold_counter()
		return false

func reset_hold_counter() -> void:
	hold_counter = 0.0

func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "The PlayerState state type must be used only in the player scene. It needs the owner to be a Player node.")

func apply_movement(target_velocity: Vector3, delta: float, accel: float, turn_speed: float) -> void:
	## Accelerate in target direction
	player.velocity.x = move_toward(player.velocity.x, target_velocity.x, delta * accel)
	player.velocity.z = move_toward(player.velocity.z, target_velocity.z, delta * accel)
	
	extra_rotation(target_velocity.normalized(), delta, turn_speed)

func extra_rotation(target_direction: Vector3, delta: float, turn_speed: float):
	## Apply an extra rotation to the velocity to make turns feel more responsivar
	var speed_vector = player.velocity
	speed_vector.y = 0.0
	var current_speed = speed_vector.length()
	var current_direction = speed_vector.normalized()
	var new_direction = current_direction.slerp(target_direction, delta * turn_speed)
	player.velocity.x = new_direction.x * current_speed
	player.velocity.z = new_direction.z * current_speed
