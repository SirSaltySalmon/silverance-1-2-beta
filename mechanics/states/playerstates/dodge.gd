extends PlayerGroundState

@export var dodge_timer: Timer
@export var invulnerability_timer: Timer
@export var recently_dodged: Timer
# The time window since dodging that will make an attack become a dodge attack 
@export var dodge_attack_window: float = 0.3

var no_input : bool
var input_dir_2d : Vector2
var input_dir : Vector3

func _ready() -> void:
	super()
	dodge_timer.connect("timeout", finished_dodging)
	invulnerability_timer.connect("timeout", end_of_invulnerability)

func end_of_invulnerability() -> void:
	player._make_vulnerable_to_attacks()

func finished_dodging() -> void:
	if player.attack_buffer.should_run_action():
		player.attack_type = "DODGE"
		next_state.emit("Attack")
	elif Input.is_action_pressed("attack"):
		next_state.emit("Charging")
	elif player.state_machine.state.name not in ["Death"]:
		if player.is_on_floor():
			next_state.emit("Idle")
		else:
			next_state.emit("Falling")

func handle_input(_event: InputEvent) -> void:
	pass

func update(delta: float) -> void:
	check_for_hold("attack", delta)

func physics_update(delta: float) -> void:
	apply_drag(0.0, delta) # Halved deceleration
	if no_input:
		player.face_opposite_velocity_direction(delta)
	else:
		player.face_target_if_possible(delta)

func enter(_previous_state: State, _data := {}) -> void:
	dodge_timer.start(player.dodge_time)
	invulnerability_timer.start(player.dodge_invul_time)
	player._make_invul_to_attacks()
	
	## True if no_input, else false
	no_input = player.input_dir_2d == Vector2.ZERO
	## Put down automatic input for dodging backwards if no input
	input_dir_2d = Vector2(0, -1) if no_input else player.input_dir_2d
	# Calculate direction as backwards from the rig, not the camera,
	# so the behavior is more predictable for player
	input_dir = (player._calculate_3d_dir(input_dir_2d, player._get_rig_rotation().y)
				if no_input else player.input_dir)
	
	# Calculate dodge animation based on appearance, aka rig rotation.
	_dodge_animation()
	
	# Finally, apply the actual dodging velocity.
	player.velocity.x = input_dir.x * player.dodge_impulse
	player.velocity.z = input_dir.z * player.dodge_impulse

func exit() -> void:
	player.anim_tree["parameters/GroundStates/insta_trans/transition_request"] = "Ground"
	recently_dodged.start(dodge_attack_window)
	## Cleanup in case dodge is interrupted before timer ends
	player._make_vulnerable_to_attacks()

func _dodge_animation() -> void:
	animate_insta("Dodge")
	# Default dodging backwards animation if no input
	if no_input:
		player.anim_tree["parameters/GroundStates/DodgeBlend/blend_position"] = input_dir_2d
		return
	
	# Transform this world-space direction into the rig's local space
	var rig_basis = player._get_rig_transform()
	var local_dir = (input_dir * rig_basis).normalized()
	# (x is mirrored however, unknown cause)
	var blend_pos = Vector2(-local_dir.x, local_dir.z)
	player.anim_tree["parameters/GroundStates/DodgeBlend/blend_position"] = blend_pos
