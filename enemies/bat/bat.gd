extends CharacterBody2D
class_name Bat

var speed: float
var acceleration: float
@export var hc: HealthComponent
@export var arena_bounds: ArenaBounds
var dir:= Vector2.ZERO
var bullet:= preload("res://enemies/bat/bat_bullet.tscn")
@export var timer: Timer
var player_ref: Player
var config: ScoreConfig

var knockback := Vector2.ZERO
var shots_fired := 0

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("Player")
	assert(player_ref)
	config = player_ref.sm.config
	speed = config.bat_speed
	acceleration = config.bat_acceleration
	hc.max_health = config.bat_health
	hc.health = config.bat_health
	hc.damage_taken.connect(flash_red)
	hc.died.connect(death)
	timer.wait_time = randf_range(config.bat_fire_interval_min, config.bat_fire_interval_max)

func death():
	var score_increment = config.bat_points_on_kill + randi_range(-config.bat_points_on_kill_variance, config.bat_points_on_kill_variance)
	player_ref.sm.change_score(score_increment, global_position)
	queue_free()
	
func flash_red(dmg_taken:int):
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func _process(delta: float) -> void:
	#reduce knockback value over time
	knockback = knockback.move_toward(Vector2.ZERO, 14000 * delta)
		
	if is_instance_valid(player_ref):
	
		dir = (player_ref.global_position - global_position).normalized()
		velocity = velocity.move_toward(dir * speed, acceleration * delta)
		var dist_to_player = global_position.distance_to(player_ref.global_position)
		if dist_to_player < config.bat_keep_away_distance:
			velocity = velocity.move_toward(-dir * speed, acceleration * config.bat_flee_acceleration_mult * delta)
		velocity += knockback
		$Sprite2D.flip_h = dir.x < 0.0 # player is to the left, so the zombie is approaching from the left

	move_and_slide()
	arena_bounds.apply(delta)
		
	
func _on_timer_timeout() -> void:
	timer.wait_time = randf_range(config.bat_fire_interval_min, config.bat_fire_interval_max)
	shoot()
func apply_frost():
	$Frost.apply(config.mage_frost_slow, config.zombie_speed, config.mage_slow_duration)

func shoot():

	shots_fired += 1
	var b = bullet.instantiate() as BatBullet
	b.global_position = global_position
	b.special = shots_fired % 3 == 0
	b.initialize(config)
	b.dir = (player_ref.global_position - global_position).normalized()
	get_tree().root.add_child(b)
	$Sprite2D.play("shoot")

func apply_knockback(from_position: Vector2) -> void:
	var dir = (global_position - from_position).normalized()
	knockback = dir * config.bat_knockback_force


func _on_sprite_2d_animation_finished() -> void:
	if $Sprite2D.animation == 'shoot':
		$Sprite2D.play("idle")
