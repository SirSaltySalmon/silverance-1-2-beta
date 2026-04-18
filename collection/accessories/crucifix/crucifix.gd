extends Accessory

func trigger_passive():
	wearer.add_multiplier("Crucifix" + str(slot), "res", 0.2, "Poise")

func remove_passive():
	wearer.remove_multiplier("Crucifix" + str(slot), "res")
