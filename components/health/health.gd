extends Node
class_name HealthComponent

@export var max_health: int = 10
@export var use_health: bool = true
var health 

signal damage_taken(damage_taken: int)
signal damage_healed
signal died

func _ready() -> void:
	health = max_health
	

func take_damage(dmg: int):
	if dmg <= 0: # No damage, no hit reaction (e.g. frost's slow-only impact).
		return

	if use_health:
		health -= dmg

		if health <= 0:
			death()
			return

		damage_taken.emit(dmg)
	else: #The player doesn't use health, rahter score. So just emit damage taken for another thing to handle
		damage_taken.emit(dmg)

func death(): 
	died.emit()
