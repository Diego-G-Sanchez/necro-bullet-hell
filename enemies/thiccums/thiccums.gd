extends CharacterBody2D
class_name Thiccums

var speed: float
@export var acceleration:float = 100.0
@export var aura_tick_interval: float = 0.5
@onready var hc: HealthComponent = %Health
@onready var sprite: AnimatedSprite2D = $Sprite2D
@onready var light: PointLight2D = $PointLight2D
@export var arena_bounds: ArenaBounds
var config: ScoreConfig
var dir:= Vector2.ZERO
var knockback:= Vector2.ZERO
var player_ref: Player
var initial_scale: Vector2
var light_offset_x: float

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
	config = player_ref.sm.config
	speed = config.thiccums_speed
	hc.max_health = config.thiccums_health
	hc.health = config.thiccums_health
	initial_scale = scale
	light_offset_x = light.position.x
	hc.damage_taken.connect(_on_damage_taken)
	hc.died.connect(death)
	$HitBox.set_damage(config.thiccums_big_aura_tick_damage)
	$AuraTick.wait_time = aura_tick_interval
	_pulse_aura_visual()

func death():
	var score_increment = config.thiccums_points_on_kill + randi_range(-config.thiccums_points_on_kill_variance, config.thiccums_points_on_kill_variance)
	player_ref.sm.change_score(score_increment, global_position)
	Globals.record_kill("thiccums")
	queue_free()

func _on_damage_taken(dmg_taken:int):
	flash_red(dmg_taken)

func flash_red(dmg_taken:int):
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func apply_knockback(from_position: Vector2) -> void:
	var knock_dir := (global_position - from_position).normalized()
	knockback = knock_dir * config.thiccums_knockback_force

func apply_frost():
	$Frost.apply(config.mage_frost_slow, config.thiccums_speed, config.mage_slow_duration)

func _process(delta: float) -> void:
	#reduce knockback value over time
	knockback = knockback.move_toward(Vector2.ZERO, 14000 * delta)

	if is_instance_valid(player_ref):
		dir = (player_ref.global_position - global_position).normalized()
		velocity = velocity.move_toward(dir * speed, acceleration * delta)
		velocity += knockback
		sprite.flip_h = dir.x < 0.0
		light.position.x = -light_offset_x if sprite.flip_h else light_offset_x
	move_and_slide()

	if velocity.length() > 1.0:
		if not sprite.is_playing():
			sprite.play("bob")
	elif sprite.is_playing():
		sprite.stop() # rewinds to frame 0, the neutral standing pose

	var ratio := maxf(float(hc.health) / float(hc.max_health), 0.125)
	scale = scale.lerp(initial_scale * ratio, 8.0 * delta)

	arena_bounds.apply(delta)

func _on_aura_tick() -> void:
	var shape: CollisionShape2D = $HitBox/CollisionShape2D
	shape.set_deferred("disabled", true)
	await get_tree().physics_frame
	if is_instance_valid(self):
		shape.set_deferred("disabled", false)

func _pulse_aura_visual() -> void:
	var aura_sprite: Sprite2D = $HitBox/AuraSprite
	var pulse := create_tween().set_loops()
	pulse.tween_property(aura_sprite, "modulate:a", 0.12, 0.6)
	pulse.tween_property(aura_sprite, "modulate:a", 0.32, 0.6)
