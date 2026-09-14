extends Node2D
class_name PlayerBullet


@export var hb: HitBox
var damage: int = 1
var speed: float = 400
var dir:= Vector2.ZERO


func initialize(config: ScoreConfig, charged: bool = false):
	if charged:
		damage = config.sharp_charged_shot_damage
		speed = config.sharp_charged_shot_speed
		scale = Vector2.ONE * config.sharp_charged_shot_scale
		$Sprite2D.modulate = Color("e6e4f0")
	else:
		damage = config.shot_damage
		speed = config.shot_speed
	hb.set_damage(damage)


func delete_bullet():
	queue_free()

func _process(delta: float) -> void:
	global_position += dir * delta * speed

func _on_lifetime_timeout() -> void:
	queue_free()
