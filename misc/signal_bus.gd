extends Node

## This global autoload manage signals that need to be broadcasted on a global level

signal attack_received(damage: int, victim: Character, attacker: Character)

signal boss_arena_entered(boss: BaseBoss)
signal rest_prepare
signal rested

signal noun_verbed(text: String, col: Color)

signal shake_camera

signal money_updated
