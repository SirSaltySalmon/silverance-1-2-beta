class_name BossBarsDisplayer
extends VBoxContainer

@export var boss_bar: PackedScene

var all_bars = []

func _ready() -> void:
	for child in get_children():
		child.queue_free()

func attach(boss: BaseBoss):
	var new_bar: BossBar = boss_bar.instantiate()
	new_bar.label.text = boss.flag
	new_bar.setup(boss)
	all_bars.append(new_bar)
	add_child(new_bar)
	return self

func detach(boss: BaseBoss):
	for bar in all_bars:
		if bar.boss == boss:
			bar.detach()
			all_bars.erase(bar)
			bar.queue_free()
			return
