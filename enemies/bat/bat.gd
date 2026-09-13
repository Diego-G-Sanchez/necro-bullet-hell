extends CharacterBody2D
class_name Bat

@export var speed:float = 110.0
@export var acceleration:float = 100.0
@export var hc: HealthComponent
var dir:= Vector2.ZERO
var bullet:= preload("res://enemies/bat/bat_bullet.tscn")
@export var timer: Timer
var player_ref: Player
var config: ScoreConfig
 
var knockback := Vector2.ZERO

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("Player")
	assert(player_ref)
	config = player_ref.sm.config
	hc.damage_taken.connect(flash_red)
	hc.died.connect(death)
	timer.wait_time = randf_range(0.8,1.2) * 2
	

func death():
	var score_increment = config.zombie_points_on_kill + randi_range(-config.zombie_points_on_kill_variance, config.zombie_points_on_kill_variance)
	player_ref.sm.change_score(score_increment, global_position)
	queue_free()
	
func flash_red(dmg_taken:int):
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func _process(delta: float) -> void:
	#reduce knockback value over time
	knockback = knockback.move_toward(Vector2.ZERO, 4000 * delta)
		
	if is_instance_valid(player_ref):
	
		dir = (player_ref.global_position - global_position).normalized()
		velocity = velocity.move_toward(dir * speed, acceleration * delta)
		var dist_to_player = global_position.distance_to(player_ref.global_position)
		if dist_to_player < 200.0:
			velocity = velocity.move_toward(-dir * speed, acceleration * 10 * delta)
		velocity += knockback
			
	move_and_slide()
		
		
func _on_timer_timeout() -> void:
	shoot()

func shoot():
	var b = bullet.instantiate() as BatBullet
	b.global_position = global_position
	b.damage = 10
	b.initialize(config)
	b.dir = (player_ref.global_position - global_position).normalized()
	get_tree().root.add_child(b)
	
func apply_knockback(from_position: Vector2, force: float) -> void:
	var dir = (global_position - from_position).normalized()
	knockback = dir * force
