class_name Weapon extends BoneAttachment3D

## Designed for humanoid characters.
## Custom characters will not be completely compatible. Using custom movesets,
## the damage values they use may be handled differently

var disabled := false
@export var connected_hitbox = false
@export var max_combo := 3
@export var hitbox: HitboxComponent
@export_enum(
	"1H",
	"2H",
	"DW"
) 		var weapon_type: String

@export var BASIC := [8, 6, 7]
@export var RUNNING := 7
@export var DODGE := 7
@export var CHARGED := 7
@export var PLUNGE := 10

@export var knockback_map: Dictionary[String, float] = {}

@export var special: PackedScene
@export var sfx: AudioStreamPlayer3D
@export var custom_sfx_path: String

var wielder: Character
var hit_characters: Array[Character]
var special_node: Special

func _ready() -> void:
	if hitbox:
		hitbox.connect("area_entered", _on_attack_connect)
	if sfx:
		sfx.stream.add_stream(0, load(custom_sfx_path if custom_sfx_path else Data.WEAPON_SFX_MAP[weapon_type]))
	if special:
		special_node = special.instantiate()
		special_node.player = wielder
		add_child(special_node)
	_reset_weapon()
	if connected_hitbox:
		SignalBus.attack_received.connect(connected_hitbox_handler)

func connected_hitbox_handler(dmg, victim, pwielder):
	if pwielder == wielder:
		if not victim in hit_characters:
			hit_characters.append(victim)

func trigger_passive():
	pass

func remove_passive():
	pass

func _process(_delta: float) -> void:
	pass

func _on_attack_connect(hit_hurtbox: Node3D) -> void:
	if disabled:
		return
	if not hit_hurtbox is Hurtbox:
		return
	var hit_character: Character = hit_hurtbox.parent
	if hit_character == null:
		printerr("No parent attached to this hurtbox!")
		return
	if hit_character in hit_characters:
		return
	if hit_character.is_on_same_team_as(wielder):
		return
	
	var damage_taken = _get_damage()
	var kb = _get_knockback()
	
	## Damage taken on health, armour and poise is calculated on hit,
	## as passing 3 variables seem silly to me lol
	hit_characters.append(hit_character)	
	hit_character.receive_attack(damage_taken, kb, wielder, wielder.attack_type == "CHARGED")
	
	SignalBus.attack_received.emit(damage_taken, hit_character, wielder)

func _get_damage() -> int:
	## Get determined damage value corresponding to attack
	if "BASIC" in wielder.attack_type:
		return BASIC[wielder.combo_counter]
	match wielder.attack_type:
		"RUNNING":
			return RUNNING
		"DODGE":
			return DODGE
		"CHARGED":
			return CHARGED
		"PLUNGE":
			return PLUNGE
	printerr("Invalid attack type, cannot determine damage")
	return 0

func _get_knockback() -> int:
	if knockback_map.has(wielder.attack_type):
		return knockback_map[wielder.attack_type]
	else:
		return 1.0

## Hitboxes are controlled by a combination of turning off and on
## the monitoring of the Area3D and disabling the collision shape.

func _enable_hitbox() -> void:
	if not hitbox:
		return
	if sfx:
		sfx.play(0.0)
	hitbox.set_deferred("monitoring", true) ## Error about flushing queries
	hitbox.collider.set_deferred("disabled", false)
	hit_characters.clear()

func _disable_hitbox() -> void:
	if not hitbox:
		return
	hitbox.set_deferred("monitoring", false)
	hitbox.collider.set_deferred("disabled", true)
	hit_characters.clear()

func _retrigger_hitbox() -> void:
	_enable_hitbox()

func _reset_weapon() -> void:
	disabled = false
	if not hitbox:
		return
	hitbox.set_deferred("monitoring", true)
	hitbox.collider.set_deferred("disabled", true)

func _disable_weapon():
	disabled = true
