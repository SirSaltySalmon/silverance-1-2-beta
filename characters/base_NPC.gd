class_name BaseNPC
extends Character

## If idle, remain in place, and play idle animation
## If target enters vision or is attacked:
## 1. set target variable to target node
## 2. await engage enemy animation
## 3. activate behavioral tree
## If target runs too far away or dies: Remove target variable
## If no target: Return to idle anim, pathfind and walk back to spawn
## If meaningful hit (not superarmored): restart() behavioral tree to interrupt all actions and check status.
## When restarted, flags will be checked.
## From there, if stunned: deactivate behavioral tree for duration
## If staggered: deactivate behavioral tree. After stagger time, reactivate behavioral tree if target.
## If death: play animation, dies, and despawn, dropping loot

@export_group("Advanced Combat")
@export var hits_til_block = 1
@export var blocks_til_parry = 1

@export_group("Nodes")
@export var behavioral_tree: BTPlayer
@export var navigator: NavigationAgent3D
@export var stats_displayer: EnemyStatsDisplayer

@export_group("Loot")
@export var loot_money: int
@export var loot_id := -1
@export var loot_type: Data.LootType
@export var loot_flag: String
@export var loot_chance := 1.0
@export var add_loot_directly_to_inventory_when_killed := false

@onready var anim_sm = anim_tree["parameters/playback"]

var id := 0

var engaged := false
var target_movement_direction := Vector2.ZERO
var target_position := Vector3.ZERO
var spawnpoint := Vector3.ZERO

func _ready():
	id = Data.npc_id_counter
	Data.npc_id_counter += 1 
	if id in Data.sav.dead_id:
		queue_free()
		return
	super()
	hit.connect(update_target)
	spawnpoint = global_position

func update_target(attacker: Character):
	if target != attacker:
		target = attacker

func hit_counter_checks():
	if state_machine.state.name in ["Stun", "Stagger"]:
		hit_counter = min(hits_til_block, hit_counter)
		return # Player should be free to punish. At most, block after stun is over
	if hit_counter >= (hits_til_block + blocks_til_parry):
		block.enable_blocking() # Auto parry to push off player
	elif hit_counter >= hits_til_block:
		block.enable_blocking(false) # Just block, doesn't parry	

func air_hit(is_health_depleted := false):
	state_machine.transition_to_next_state("AirHit", {"dies": is_health_depleted})

func health_depleted_death():
	state_machine.transition_to_next_state("Stagger", {"dies": true})

func stagger():
	state_machine.transition_to_next_state("Stagger")

func blockhit():
	state_machine.transition_to_next_state("BlockHit")
	block.disable_blocking() # Whatever need to block is fulfilled

func parry():
	state_machine.transition_to_next_state("Parry")
	block.disable_blocking()

func stun():
	state_machine.transition_to_next_state("Stun")

func bleed():
	effects.bleed()

func damaging_fall_behavior():
	kill()

func receive_deathfang(player: Player):
	state_machine.transition_to_next_state("ReceiveDeathfang", {"player_node": player})

func idle():
	to_state("Idle")

func walk_towards_target():
	assert(target != null, "Target must be an existing character")
	use_navigator(target.global_position)

func walk_towards_spawnpoint():
	use_navigator(spawnpoint)

func use_navigator(target_pos: Vector3):
	navigator.set_target_position(target_pos)
	if navigator.is_navigation_finished():
		walk_towards(target_pos)
	else:
		var next_path_position: Vector3 = navigator.get_next_path_position()
		walk_towards(next_path_position)

func walk_towards(pos: Vector3):
	target_movement_direction = Vector2.ZERO
	target_position = pos
	to_state("Walk")

func walk_at_direction(direction_2d: Vector2):
	target_movement_direction = direction_2d
	target_position = Vector3.ZERO
	to_state("Walk")

func to_state(state_path: String):
	if state_machine.state.name != state_path:
		state_machine.transition_to_next_state(state_path)

#region Animation methods for calling from BT
func animate_ground(state: String) -> void:
	anim_tree["parameters/GroundStates/states/transition_request"] = state

func animate_insta(state: String) -> void:
	anim_tree["parameters/GroundStates/insta_trans/transition_request"] = state

## Each character should get their own embedded moveset
func attack(animation_code: String):
	attack_type = animation_code ## Need this line to determine attack damage
	state_machine.transition_to_next_state("Attack") ## Needs to force a state trans and not use to_state
	## TODO: Attack is not immediately transitioning in some cases, breaking the behaviour. Needs to be fixed and investigateds
