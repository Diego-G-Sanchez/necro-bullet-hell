extends Area2D

#Scans incoming hurtboxes by group
#If in the group filter, apply the damage. Dmg could be stored on the hurtbox parent.

#Player's hitbox spawns on layer 2
#Enemy's hurtbox scans layer 2
#Player's hurtbox scans layer 3
#Enemy's hitbox spawns layer 3

@export var oppositional_group: String
@export var health_component: HealthComponent


func _on_area_entered(area: Area2D) -> void:
	if oppositional_group in area.get_groups(): 
		print("contact with the enemy")
		health_component.take_damage(1)
