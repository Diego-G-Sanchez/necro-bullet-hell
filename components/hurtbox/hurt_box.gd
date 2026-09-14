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
		if area is HitBox:
			health_component.take_damage(area.damage)
		else:
			push_error("area is not hitbox")
			
			
		#Spaghetti code 1000
		#Parry clears bullets!
		if area.is_in_group("EnemyBullet") && oppositional_group != "Player": 
			var p = area.get_parent()
			if "delete_bullet" in p: 
				p.delete_bullet()
				#Get scoremanger here then use 
		
		#Bullets hit enemies
		if area.is_in_group("PlayerBullet") && oppositional_group != "Enemy":
			var p = area.get_parent()
			if "delete_bullet" in p: 
				p.delete_bullet()
		
		if area.is_in_group("FrostExplosion") && oppositional_group != "Enemy":
			var frost_slow_target := find_parent_with_method(self, "apply_frost")
			if frost_slow_target:
				frost_slow_target.apply_frost()
				return
		
		var knockback_target := find_parent_with_method(self, "apply_knockback")
		if knockback_target:
			knockback_target.apply_knockback(area.global_position)


func find_parent_with_method(start: Node, method: StringName) -> Node:
	var current := start
	while is_instance_valid(current):
		if current.has_method(method):
			return current
		current = current.get_parent()
	return null
