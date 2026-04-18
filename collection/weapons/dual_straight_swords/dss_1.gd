extends Weapon

func trigger_passive():
	wielder.max_speed_walk += 2.0
	if wielder is Player:
		wielder.max_speed_run += 2.0

func remove_passive():
	wielder.max_speed_walk -= 2.0
	if wielder is Player:
		wielder.max_speed_run -= 2.0

## Technically, when you die, the player should just be reinstantiated, so modifying values
## relatively like this is fine and it is reset to default values anyway
