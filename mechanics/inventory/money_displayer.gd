extends Label

var current_val := 0

func _ready():
	SignalBus.connect("money_updated", update_money)
	current_val = Data.sav.money
	update_money()

func update_money():
	if current_val != Data.sav.money:
		var tween = create_tween()
		tween.tween_method(_update_counter, current_val, Data.sav.money, 1.0)
	else:
		text = "Money: " + str(Data.sav.money)

func _update_counter(new_money: int):
	text = "Money: " + str(new_money)
	current_val = new_money
