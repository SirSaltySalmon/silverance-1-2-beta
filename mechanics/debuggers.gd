extends Node3D

@export var display_state := false
@export var display_invulnerability := false
@export var display_dodge_registering := false
@export var display_attack := false
@export var display_block := false
@export var state_displayer: Label3D
@export var invul_displayer: Label3D
@export var dodge_registering_displayer: Label3D
@export var attack_displayer: Label3D
@export var block_displayer: Label3D
@export var state_machine: StateMachine
@export var character: Character

func _process(_delta: float) -> void:
	if display_state and state_displayer:
		state_displayer.show()
		state_displayer.text = "State: " + state_machine.state.name
	else:
		state_displayer.hide()
	
	if display_invulnerability and character:
		invul_displayer.show()
		invul_displayer.text = "Vulnerable: " + str(character.is_vulnerable_to_attacks)
	else:
		invul_displayer.hide()
	
	if display_dodge_registering and dodge_registering_displayer and character is Player:
		dodge_registering_displayer.show()
		# States where you can dodge from
		if state_machine.state.name in ["Walk", "Idle"]:
			dodge_registering_displayer.text = "Dodge registering " + str(state_machine.state.register_dodge)
	else:
		dodge_registering_displayer.hide()
	
	if display_attack and attack_displayer and character is Player:
		attack_displayer.show()
		attack_displayer.text = "Attack: " + str(character.attack_type)
	else:
		attack_displayer.hide()
	
	if display_block and block_displayer:
		block_displayer.show()
		block_displayer.text = "Block: " + str(character.block.blocking) + ", Parrying: " + str(character.block.can_parry(), "Punish: " + str(character.block.punish))
	else:
		block_displayer.hide()
