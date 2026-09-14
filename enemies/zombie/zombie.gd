extends CharacterBody2D
class_name Zombie

var speed: float
@export var acceleration: float = 100.0
@onready var hc: HealthComponent = %Health
@onready var sprite: AnimatedSprite2D = $Sprite2D
@export var arena_bounds: ArenaBounds
var config: ScoreConfig
var dir := Vector2.ZERO
var knockback := Vector2.ZERO
var player_ref: Player
var dying := false
const HIT_PARTICLES := preload("res://scenes/enemy_hit_particles.tscn")
const DEATH_PARTICLES := preload("res://scenes/enemy_death.tscn")


func get_player_ref():
	var player_nodes = get_tree().get_nodes_in_group("Player")
	for i in player_nodes:
		if i is Player:
			return i
	return null
	
func _ready() -> void:
	player_ref = get_player_ref()
	if player_ref == null:
		queue_free()
	assert(player_ref)
	config = player_ref.sm.config
	speed = config.zombie_speed
	hc.max_health = config.zombie_health
	hc.health = config.zombie_health
	hc.damage_taken.connect(flash_red)
	hc.died.connect(death)
	$HitBox.set_damage(config.zombie_damage)
	
func death():
	if dying:
		return
	dying = true
	hc.use_health = false
	var p = DEATH_PARTICLES.instantiate()
	p.global_position = global_position
	get_tree().root.add_child(p)
	var score_increment = config.zombie_points_on_kill + randi_range(-config.zombie_points_on_kill_variance, config.zombie_points_on_kill_variance)
	player_ref.sm.change_score(score_increment, global_position)
	Globals.record_kill("zombie")
	on_death_tween()

func on_death_tween() -> void:
	velocity = Vector2.ZERO
	knockback = Vector2.ZERO
	$HitBox.set_deferred("monitorable", false)
	$HitBox.set_deferred("monitoring", false)
	$HitBox/CollisionShape2D.set_deferred("disabled", true)
	$HurtBox.set_deferred("monitoring", false)
	$HurtBox.set_deferred("monitorable", false)
	$HurtBox/CollisionShape2D.set_deferred("disabled", true)
	$Frost/Timer.stop()
	$AnimationPlayer.stop()
	sprite.pause()

	var fall_sign := -1.0 if randi() % 2 == 0 else 1.0
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "modulate", Color.RED, 0.2)
	tween.tween_property(self, "modulate:a", .0, 0.5).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "rotation_degrees", fall_sign * 90.0, 0.3)
	tween.tween_property(self, "position:x", fall_sign * 56.0, 0.5) \
		.as_relative()
	tween.chain().tween_callback(queue_free)
	
func flash_red(dmg_taken: int):
	if dying:
		return
	var p = HIT_PARTICLES.instantiate()
	p.global_position = global_position
	get_tree().root.add_child(p)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
func apply_knockback(from_position: Vector2) -> void:
	if dying:
		return
	var knock_dir := (global_position - from_position).normalized()
	knockback = knock_dir * config.zombie_knockback_force
	
func apply_frost():
	if dying:
		return
	$Frost.apply(config.mage_frost_slow, config.zombie_speed, config.mage_slow_duration)

func _process(delta: float) -> void:
	if dying:
		return
	#reduce knockback value over time
	knockback = knockback.move_toward(Vector2.ZERO, 14000 * delta)
		
	if is_instance_valid(player_ref):
		dir = (player_ref.global_position - global_position).normalized()
		velocity = velocity.move_toward(dir * speed, acceleration * delta)
		velocity += knockback
		sprite.flip_h = dir.x < 0.0 # player is to the left, so the zombie is approaching from the left
	move_and_slide()

	if velocity.length() > 1.0:
		if not sprite.is_playing():
			sprite.play("bob")
	elif sprite.is_playing():
		sprite.stop() # rewinds to frame 0, the neutral standing pose
	
	arena_bounds.apply(delta)
