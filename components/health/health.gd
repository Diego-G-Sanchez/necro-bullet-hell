extends Node
class_name HealthComponent

@export var max_health: int = 10
@export var use_health: bool = true
var health 

signal damage_taken
signal damage_healed
signal died

func _ready() -> void:
	health = max_health
	

func take_damage(dmg: int):
	if use_health:
		health -= dmg
		
		if health <= 0:
			death()
			return
		
		damage_taken.emit()
	else: #The player doesn't use health, rahter score. So just emit damage taken for another thing to handle
		damage_taken.emit()

func death(): 
	died.emit()
