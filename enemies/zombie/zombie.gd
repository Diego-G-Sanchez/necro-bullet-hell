extends CharacterBody2D
class_name Zombie

var speed: float
@export var acceleration:float = 100.0
@onready var hc: HealthComponent = %Health
@onready var sprite: AnimatedSprite2D = $Sprite2D
@export var arena_bounds: ArenaBounds
var config: ScoreConfig
var dir:= Vector2.ZERO
var knockback:= Vector2.ZERO
var player_ref: Player


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
	var score_increment = config.zombie_points_on_kill + randi_range(-config.zombie_points_on_kill_variance, config.zombie_points_on_kill_variance)
	player_ref.sm.change_score(score_increment, global_position)
	Globals.record_kill("zombie")
	queue_free()
	
func flash_red(dmg_taken:int):
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)
	
func apply_knockback(from_position: Vector2) -> void:
	var knock_dir := (global_position - from_position).normalized()
	knockback = knock_dir * config.zombie_knockback_force
	
func apply_frost():
	$Frost.apply(config.mage_frost_slow, config.zombie_speed, config.mage_slow_duration)

func _process(delta: float) -> void:
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
