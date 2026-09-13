extends CharacterBody2D
class_name Player

@export_group("Components")
@export var health_component: HealthComponent
@export var sm: ScoreManager
@export var arena_bounds: ArenaBounds
@export var walk_sound: AudioStreamPlayer2D

# Top-down movement + a hand rig that aims at the cursor.
# HandRig lives in a ring around the player (inner..outer radius), faces the
# mouse, and pulls inward when the cursor is closer than the outer offset.
# HandL/HandR keep a Y-only rest pose so an AnimationPlayer on the rig can
# own their pose. Body and hands are scaled independently.

@export_group("Movement")
@export var max_speed := 220.0
@export var acceleration := 2000.0
@export var friction := 2400.0

@export_group("Scale")
@export var body_scale := 4.0
@export var hand_scale := 3.0

@export_group("Hands")
@export var hand_radius := 18.0
## Inner hole of the aim ring. Hands can pull in to this distance when the
## mouse is closer than hand_radius, but never closer to the player.
@export var hand_inner_radius := 10.0
@export var hand_separation := 25.0
@export var aim_speed := 22.0
@export var body_faces_mouse := true

@export_group("Animation")
## Bob playback speed while walking. The bob is stopped entirely while idle.
@export var walk_anim_speed := 1.6

@onready var body: AnimatedSprite2D = $Body
@onready var hand_rig: Node2D = $HandRig
@onready var hand_l: Sprite2D = $HandRig/HandL
@onready var hand_r: Sprite2D = $HandRig/HandR
@onready var dash: Dash = $Dash


var aim_point := Vector2.INF
var _hand_offset := 18.0


const FLIP_DEADZONE := deg_to_rad(10.0)
var _aiming_left := false

enum Hands {
	Wolf,
	Shooter,
	Mage,
}

var hand_state: Hands = Hands.Wolf

#Store the active cooldown values here. 
var wolf_parry_cd: float = 0.0
var wolf_claw_cd: float = 0.0
var sharp_shoot_cd: float = 0.0
var sharp_dash_cd: float = 0.0
var mage_frost_cd: float = 0.0
var mage_fireball_cd: float = 0.0


func _ready() -> void:
	# Starts stopped; the bob only runs while a movement key is held.
	body.stop()
	hand_l.position = Vector2(0, -hand_separation)
	hand_r.position = Vector2(0, hand_separation)
	_hand_offset = hand_radius

	#Connect to the healthComponent
	health_component.damage_taken.connect(take_score_damage)

	
func take_score_damage(dmg_taken):
	if sm.score > 0:
		sm.change_score(-dmg_taken, global_position)
		flash_red()
		Sfx.play(preload("res://sounds/sfx/hitHurt.wav"))

func flash_red():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.RED, 0.1)
	tween.tween_property(self, "modulate", Color.WHITE, 0.1)

func get_aim_point() -> Vector2:
	return get_global_mouse_position() if aim_point == Vector2.INF else aim_point


func _physics_process(delta: float) -> void:
	#The Dash node moves the player while a dash is active.
	if dash.is_dashing():
		return

	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
		if walk_sound.playing == false:
			walk_sound.pitch_scale = randf_range(.13,.16)
			walk_sound.playing = true
		if !$AnimationPlayer.is_playing(): 
			$AnimationPlayer.play("walk")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		if $AnimationPlayer.is_playing(): 
			$AnimationPlayer.stop()
	move_and_slide()
	arena_bounds.apply(delta)

	if input_dir != Vector2.ZERO:
		body.speed_scale = walk_anim_speed
		if not body.is_playing():
			body.play("bob")
	elif body.is_playing():
		body.stop() # rewinds to frame 0, the neutral standing pose


func _process(delta: float) -> void:
	var to_aim := get_aim_point() - global_position
	var blend := 1.0 - exp(-aim_speed * delta)
	if to_aim.length_squared() > 0.0001:
		hand_rig.rotation = lerp_angle(hand_rig.rotation, to_aim.angle(), blend)
	var inner := minf(hand_inner_radius, hand_radius)
	var target_radius := clampf(to_aim.length(), inner, hand_radius)
	_hand_offset = lerpf(_hand_offset, target_radius, blend)
	_apply_rig()


	var from_right := absf(wrapf(hand_rig.rotation, -PI, PI))
	if _aiming_left and from_right < PI * 0.5 - FLIP_DEADZONE:
		_aiming_left = false
	elif not _aiming_left and from_right > PI * 0.5 + FLIP_DEADZONE:
		_aiming_left = true

	if body_faces_mouse:
		body.flip_h = _aiming_left

	decrement_cooldowns(delta)


func _apply_rig() -> void:
	body.scale = Vector2.ONE * body_scale
	hand_l.scale = Vector2.ONE * hand_scale
	hand_r.scale = Vector2.ONE * hand_scale
	hand_rig.position = Vector2(_hand_offset, 0).rotated(hand_rig.rotation)
	
	
func decrement_cooldowns(delta: float) -> void:
	wolf_parry_cd = maxf(wolf_parry_cd - delta, 0.0)
	wolf_claw_cd = maxf(wolf_claw_cd - delta, 0.0)
	sharp_shoot_cd = maxf(sharp_shoot_cd - delta, 0.0)
	sharp_dash_cd = maxf(sharp_dash_cd - delta, 0.0)
	mage_frost_cd = maxf(mage_frost_cd - delta, 0.0)
	mage_fireball_cd = maxf(mage_fireball_cd - delta, 0.0)
