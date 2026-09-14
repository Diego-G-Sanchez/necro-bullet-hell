extends Node2D
class_name PlayerBulletFireball


const PARTICLES_SCENE := preload("res://scenes/fireball_particles.tscn")
signal deleting

@export var hb: HitBox
@export var explosion: PackedScene
var damage: int = 0
var speed: float = 400
var dir:= Vector2.ZERO

var c: ScoreConfig

func create_explosion(c):
	var e = explosion.instantiate() as Explosion
	e.global_position = global_position
	get_tree().root.add_child.call_deferred(e)
	e.initialize(c)
	queue_free()
	
func initialize(config: ScoreConfig):
	c = config
	damage = 0
	speed = config.shot_speed
	Sfx.play(preload("res://sounds/sfx/shoot_fire.wav"))
	hb.set_damage(damage)
	_spawn_particles()


func _spawn_particles() -> void:
	var particles = PARTICLES_SCENE.instantiate()
	add_child(particles)
	particles.setup(self)


func delete_bullet():
	deleting.emit()
	create_explosion(c)

func _process(delta: float) -> void:
	global_position += dir * delta * speed

func _on_lifetime_timeout() -> void:
	delete_bullet()
