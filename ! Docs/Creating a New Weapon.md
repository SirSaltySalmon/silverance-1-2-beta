# CREATING A NEW WEAPON

## DESCRIPTION
This is a guide for creating new weapons. Weapons are kinda silly and may have multiple scenes for
one weapon. Because of that, we use packed scene arrays to store them. Weapons currently are
developed as player-use only, but it will also be very easy to make NPC use the same weapons.

## GUIDE
1. New scene inheriting from Weapon class which is BoneAttachment3D
2. Model of weapon as MeshInstance3D
3. New HitboxComponent, and a CollisionShape3D child for the hitbox
4. Set weapon properties:
	a. [Max Combo] - Most weapons will probably only have a 3 combo due to scope
	b. [Attach HitboxComponent]
	c. [Weapon Type] - Determines animations ## May also determine some DMG mults in the future
	d. Damage Data for each attack type: [BASIC, RUNNING, DODGE, CHARGED, PLUNGE]
	
