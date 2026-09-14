extends Node
class_name EnemyHurtSound

@export var health_component: HealthComponent
@export var hurt_sounds: Array[AudioStream] = [
	preload("res://sounds/sfx/enemyHurt1.wav"),
	preload("res://sounds/sfx/enemyHurt2.wav"),
	preload("res://sounds/sfx/enemyHurt3.wav"),
]


func _ready() -> void:
	if health_component == null:
		return
	health_component.damage_taken.connect(_on_damage_taken)
	health_component.died.connect(_on_died)


func _on_damage_taken(_dmg: int) -> void:
	_play()


func _on_died() -> void:
	_play()


func _play() -> void:
	if hurt_sounds.is_empty():
		return
	var pos := Vector2.ZERO
	var parent := get_parent()
	if parent is Node2D:
		pos = parent.global_position
	Sfx.play(hurt_sounds.pick_random(), pos)
