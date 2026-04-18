# CREATING A NEW CHARACTER

## DESCRIPTION
This is a guide for creating new characters and NPCs. It is important to follow all these steps,
or you would end up with missing attributes and erros that become virtually undetectable.
We don't want that, so I'll probably add more printerr and debugging messages in the future. But
for now, following these will be easiest!

## GUIDE
1. New scene inheriting from Character
2. Set appropriate Collision properties:
	a. Layer: Only 2 (Player) or 3 (Enemies)
	b. Mask: 1, 2, and 3 (Terrain, Players, and Enemies)
2. Attach required nodes:
	a. Rig (Node3D) with %GeneralSkeleton Child (Skeleton3D) if it has one
	b. CollisionBox (CollishionShape3D with any shape)
3. Attach combat-related nodes:
	a. if Player:
		* PlayerStateMachine [Attach Player]
		* BlockComponent [Attach Player]
		* ScreenUI (Control):
			- HealthComponent
			- PoiseComponent
			- ArmourComponent
		* StaminiaDisplayer (Sprite3D), [Attach SubViewport Texture containing StaminaComponent]
		(Player exclusive, so not that important)
		* ThirdPersonCamera
		* DummyRig (Empty Node3D, just for animation adjustments)
	b. if NPC:
		* ## Didn't get here yet, but StateMachine / BehaviouralTree for manipulating behaviour
		* EnemyStatDisplayer (Sprite3D), [Attach SubViewport Texture]:
			- HealthComponent
			- PoiseComponent
			- ArmourComponent
		* BlockComponent [Attach NPC]
4. Attach nodes to character and set properties:
	a. Movement Data [Accel, Max Speed Walk, Turn Speed] - Defaults are usually fine
	b. Combat Data [Team] - PLAYER or ENEMY, important as helpful NPCs may be on PLAYER team,
	and invading players may be on ENEMY team.
	c. Weapon Data [Active Weapon Scene] - Set the weapon the character spawns with.
	[Sheathed Weapon Scene] can also be set on characters who can change weapons.
	d. Multipliers [General, Health, Poise, and Armour DMG and Res] - Defaults are usually fine,
	can change for gimmicky weapons. ## Might add weapon-type-based mults or more in the future
	e. Nodes [Attach the following]:
		* ## BehaviouralTree if NPC
		* HealthComponent
		* ArmourComponent
		* PoiseComponent
		* BlockComponent
		* Rig
		* Skeleton
		* Anim Player
		* Anim Tree
		* State Machine
	
	...if Player:
	f. Player Movement - Defaults are usually fine
	g. Nodes [Attach the following]:
		* Camera
		* Recently Dodged Timer
		* StaminaComponent
		* Target Indicator (Sprite that will appear above locked-on target's head)
		* Dummy Rig
5. Set node properties:
	a. HealthComponent [Parent, Max Health]
	b. PoiseComponent [Parent, Max Poise, Regen CD, Regen Multiplier]
	c. ArmourComponent [Parent, Max Armour, Regen CD]
	d. Weapon Data ## Which is in its own section
6. Set animations:
	a. Import a default humanoid anim or otherwise
	b. Allow the ATTACKMOVESET / Player Movesets to transition to self (IMPORTANT)
