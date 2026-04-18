extends Node

func wait(time : float):
	await get_tree().create_timer(time).timeout
	return

func create_texture(path: String):
	return load(path)

func get_closest(target: Node3D, arr: Array):
	assert(not arr.is_empty(), "This inputted array should not be empty.")
	
	var smallest_dist := 0.0
	var smallest_index := 0
	for i in range(arr.size()):
		var dist = target.global_position.distance_squared_to(arr[i].global_position)
		if dist < smallest_dist:
			smallest_dist = dist
			smallest_index = i
	return arr[smallest_index]
