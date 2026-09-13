extends Node2D
class_name BatBullet


@export var hb: HitBox
var damage: int = 1
var speed: float = 150
var dir:= Vector2.ZERO


func initialize(config: ScoreConfig):
	damage = config.bat_bullet_damage
	speed = config.bat_bullet_speed
	hb.set_damage(damage)

func delete_bullet():
	queue_free()

func _process(delta: float) -> void:
	global_position += dir * delta * speed
