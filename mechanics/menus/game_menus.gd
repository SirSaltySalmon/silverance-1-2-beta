class_name GameMenus
extends BaseUI

@export var ui_to_hide: Control
@export var weapons: MenuPanel
@export var weapon_display: WeaponDisplay
@export var accessories: MenuPanel
@export var questlog: MenuPanel
@export var fast_travel: MenuPanel
var is_opened = false

signal menu_closed

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		if is_opened:
			close()
		else:
			open()

func open(campfire := false):
	is_opened = true
	ui_to_hide.fade_out()
	fade_in()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if campfire:
		_on_fast_travel_pressed()
	else:
		_on_weapons_pressed()
		

func close():
	is_opened = false
	if not weapon_display.visible:
		weapon_display.fade_in()
	ui_to_hide.fade_in()
	fade_out()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	emit_signal("menu_closed")
	

func _on_weapons_pressed() -> void:
	hide_all()
	weapons.show()
	weapon_display.show()
	weapons.load_menu()

func _on_accessories_pressed() -> void:
	hide_all()
	accessories.show()
	accessories.load_menu()

func _on_quest_log_pressed() -> void:
	hide_all()
	questlog.show()
	questlog.load_menu()

func hide_all():
	weapon_display.hide()
	weapons.hide()
	accessories.hide()
	questlog.hide()
	fast_travel.hide()


func _on_fast_travel_pressed() -> void:
	hide_all()
	fast_travel.show()
	fast_travel.load_menu()
