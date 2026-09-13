extends Area2D
class_name HitBox

#Attach the damage to the hitbox when the entity uses an attack
var damage:= 0

func set_damage(dmg: int):
	damage = dmg
