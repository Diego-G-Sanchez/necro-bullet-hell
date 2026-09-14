extends Node2D
class_name PlayerBullet


const PARTICLES_SCENE := preload("res://scenes/playerbullet_particles.tscn")

signal deleting

@export var hb: HitBox
var damage: int = 1
var speed: float = 400
var dir:= Vector2.ZERO


func initialize(config: ScoreConfig, charged: bool = false):
	if charged:
		damage = config.sharp_charged_shot_damage
		speed = config.sharp_charged_shot_speed
		scale = Vector2.ONE * config.sharp_charged_shot_scale
	else:
		damage = config.shot_damage
		speed = config.shot_speed
	hb.set_damage(damage)
	_spawn_particles(charged)


func _spawn_particles(charged: bool) -> void:
	var particles = PARTICLES_SCENE.instantiate()
	add_child(particles)
	particles.setup(self)
	if charged:
		particles.amount *= 3


func delete_bullet():
	deleting.emit()
	queue_free()

func _process(delta: float) -> void:
	global_position += dir * delta * speed

func _on_lifetime_timeout() -> void:
	delete_bullet()
