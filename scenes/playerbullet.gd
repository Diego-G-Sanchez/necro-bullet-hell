extends Node2D
class_name PlayerBullet


@export var hb: HitBox
var damage: int = 1
var speed: float = 400
var dir:= Vector2.ZERO


func initialize(config: ScoreConfig):
	damage = config.shot_damage
	speed = config.shot_speed
	hb.set_damage(damage)


func delete_bullet():
	queue_free()

func _process(delta: float) -> void:
	global_position += dir * delta * speed

func _on_lifetime_timeout() -> void:
	queue_free()
