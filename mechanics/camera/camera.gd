class_name ThirdPersonCamera extends Node3D

@export var disabled: bool
@export var player: Player
@export var camera_target: Node3D
@export var camera3d: Camera3D
@export var spring_arm: SpringArm3D
@export var dummy: Node3D
@export var shaker: ShakerComponent3D
@export var shaker_short: ShakerComponent3D
@export var pitch_max := 50
@export var pitch_min := -50
@export var sensitivity := 0.002
@export var smoothness := 8
@export var rotation_tween_duration := 0.5
@export var distance_tween_duration := 0.5
@export var reset_pitch := -20
@export var spring_length_default := 4.0
@export var spring_length_max := 5.0
@export var zoom_length := 3.0
var yaw: float
var pitch: float
var target_rotation := Vector3(reset_pitch, 0, 0)

## For handling lock on
var visible_targets: Array[Character]

## Player is TP'd to the location they spawn in. So camera shouldn't be doing anything til then.
var is_player_ready := false

var modify_spring_arm_length := true

# If falling, stop and just look at player
var falling := false

func _ready() -> void:
	SignalBus.connect("shake_camera", shake)
	DialogueManager.connect("dialogue_started", zoom_in)
	DialogueManager.connect("dialogue_ended", zoom_out)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await owner.ready
	is_player_ready = true
	global_position = owner.global_position

func get_nearest_visible_target(excluded_target: Character = null) -> Node3D:
	visible_targets = visible_targets.filter(is_not_dead)
	
	if visible_targets == []:
		return null
	
	var nearest_distance := INF
	var nearest_target: Node3D = null
	
	for i in range(visible_targets.size()):
		var target := visible_targets[i]
		if target == excluded_target:
			continue
		
		var current_distance := camera_target.global_position.distance_squared_to(target.global_position)
		if current_distance < nearest_distance:
			nearest_distance = current_distance
			nearest_target = target
			
	return nearest_target

func is_not_dead(char: Character):
	return not char.dead

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw += -event.relative.x * sensitivity
		pitch += -event.relative.y * sensitivity

func _process(delta: float) -> void:
	if disabled:
		return
	
	if falling:
		rotate_camera_to_point_at(player.global_position)
	elif player.target:
		rotate_camera_lock_on()
	
	# Keep the pitch value between the min and max
	pitch = clamp(pitch, deg_to_rad(pitch_min), deg_to_rad(pitch_max))
	
	# Uses lerpf to smoothly move the camera to the desired yaw and pitch
	camera_target.rotation.y = lerp_angle(camera_target.rotation.y, yaw, delta * smoothness)
	camera_target.rotation.x = lerp_angle(camera_target.rotation.x, pitch, delta * smoothness)
	
	if modify_spring_arm_length:
		adjust_distance_by_current_speed(delta)
	
	if is_player_ready and not falling:
		global_position = lerp(global_position, player.global_position, delta * smoothness)

func zoom_in(arbitrary = true):
	modify_spring_arm_length = false
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(spring_arm, "spring_length", zoom_length, 0.5)

func zoom_out(arbitrary = true):
	modify_spring_arm_length = true
	# then the function below lerps it back

func adjust_distance_by_current_speed(delta: float) -> void:
	var difference_max = player.max_speed_run - player.max_speed_walk - 1.0
	var horizontal_velocity = Vector3(player.velocity.x, 0, player.velocity.z)
	var difference_current = clamp(horizontal_velocity.length() - player.max_speed_walk, 0.0, difference_max)
	var proportion = float(difference_current) / float(difference_max)
	
	var spring_length_difference_max = spring_length_max - spring_length_default
	var target_spring_length = spring_length_default + spring_length_difference_max * proportion
	spring_arm.spring_length = lerp(spring_arm.spring_length, target_spring_length, delta * 10.0)

func rotate_camera_lock_on() -> void:
	rotate_camera_to_point_at(player.target.global_position)

func rotate_camera_to_point_at(pos: Vector3):
	dummy.look_at(pos, Vector3.UP)
	var target_rot = dummy.global_transform.basis.get_euler()
	
	yaw = target_rot.y
	pitch = target_rot.x

func position_camera_behind_player() -> void:
	## Set the target rotation to the rotation + 180, essentially behind the character
	reset_camera_rotation(player._get_rig_rotation().y + PI)

func set_camera_behind_player() -> void:
	## For spawning player in.
	reset_camera_rotation(player._get_rig_rotation().y + PI)
	camera_target.rotation.y = yaw
	camera_target.rotation.x = pitch

func set_camera_in_front_of_player() -> void:
	## For spawning player in.
	reset_camera_rotation(player._get_rig_rotation().y)
	camera_target.rotation.y = yaw
	camera_target.rotation.x = pitch

func reset_camera_rotation(target_yaw: float):
	## This is to make sure the target rotation is the shortest path to rotate,
	## not rotating like 3 loops or something
	target_yaw = wrapf(target_yaw, rotation.y - PI, rotation.y + PI)
	yaw = target_yaw
	pitch = deg_to_rad(reset_pitch)

func tween_distance(target_distance: float, duration := distance_tween_duration):
	var tween = get_tree().create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(spring_arm, "spring_length", target_distance, duration)

func shake():
	shaker.intensity = Config.get_config("VideoSettings", "CameraShake", 1.0)
	shaker.play_shake()

func shake_short():
	shaker_short.intensity = Config.get_config("VideoSettings", "CameraShake", 1.0)
	shaker_short.play_shake()

func _on_target_range_body_entered(body: Node3D) -> void:
	if body is not Character:
		return
	visible_targets.append(body)

func _on_target_range_body_exited(body: Node3D) -> void:
	visible_targets.erase(body)
