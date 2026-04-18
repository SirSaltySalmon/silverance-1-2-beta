extends StaticBody3D

@export var skele_1: PackedScene
@export var skele_2: PackedScene
@export var pick_a_fight_hitbox: PackedScene
@export var count := 50
@export var rad := 200.0

func _ready():
	spawn_random(skele_1)
	spawn_random(skele_2)

func spawn_random(skele: PackedScene):
	for i in range(count):
		var random_pos
		while not random_pos or not Vector3.ZERO.distance_to(random_pos) < rad:
			random_pos = Vector3(randf_range(-rad, rad), 0, randf_range(-rad, rad))
		var skele_obj: Character
		skele_obj = skele.instantiate()
		var hitbox = pick_a_fight_hitbox.instantiate()
		hitbox.parent = skele_obj
		skele_obj.rig.add_child(hitbox)
		add_child(skele_obj)
		skele_obj.global_position = random_pos
		
