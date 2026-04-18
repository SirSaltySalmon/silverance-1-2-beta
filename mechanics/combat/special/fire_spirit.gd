extends Special

var current_instance: Node3D

func trigger():
	if player.has_multiplier("Fire Spirit", "dmg"):
		player.remove_multiplier("Fire Spirit", "dmg")
	
	if current_instance != null:
		if is_instance_valid(current_instance):
			current_instance.queue_free()
	
	player._animate_switch_weapon() # Uses the same animation
	SignalBus.shake_camera.emit()
	player.add_multiplier("Fire Spirit", "dmg", 0.5, "Health", 20)
	add_effects()
	current_instance.play_explosion()

func add_effects():
	current_instance = effects.duplicate()
	player.add_child(current_instance)
	current_instance.play_effects()

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if not player:
		return
	if current_instance == null:
		return
	if not player.has_multiplier("Fire Spirit", "dmg"):
		disable_current_instance()

func disable_current_instance():
	if current_instance:
		if is_instance_valid(current_instance):
			current_instance.kill()
			current_instance = null
