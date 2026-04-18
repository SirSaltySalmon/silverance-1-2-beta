class_name BossBar
extends VBoxContainer

@export var label: Label
var boss: BaseBoss
var health: HealthComponent
var poise: PoiseComponent
var armour: ArmourComponent

func setup(pboss: BaseBoss):
	boss = pboss
	label.text = boss.flag
	health = boss.health
	poise = boss.poise
	armour = boss.armour
	
	health.reparent(self)
	poise.reparent(self)
	armour.reparent(self)

func detach():
	var stat = boss.stats_displayer.holder
	label.text = ""
	
	health.reparent(stat)
	poise.reparent(stat)
	armour.reparent(stat)
