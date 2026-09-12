extends CharacterBody2D

# Top-down movement + a hand rig that aims at the cursor.
# The body and the hands are scaled independently on purpose: the body sprite
# is a child of this node at body_scale, the hands live under HandRig at
# hand_scale, and neither inherits the other's scale.

@export_group("Movement")
@export var max_speed := 220.0
@export var acceleration := 2000.0
@export var friction := 2400.0

@export_group("Scale")
@export var body_scale := 4.0
@export var hand_scale := 3.0

@export_group("Hands")
@export var hand_radius := 18.0
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


var aim_point := Vector2.INF


const FLIP_DEADZONE := deg_to_rad(10.0)
var _aiming_left := false


func _ready() -> void:
	# Starts stopped; the bob only runs while a movement key is held.
	body.stop()


func get_aim_point() -> Vector2:
	return get_global_mouse_position() if aim_point == Vector2.INF else aim_point


func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_dir != Vector2.ZERO:
		velocity = velocity.move_toward(input_dir * max_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	move_and_slide()


	if input_dir != Vector2.ZERO:
		body.speed_scale = walk_anim_speed
		if not body.is_playing():
			body.play("bob")
	elif body.is_playing():
		body.stop()  # rewinds to frame 0, the neutral standing pose


func _process(delta: float) -> void:
	_apply_rig()


	var target := global_position.angle_to_point(get_aim_point())
	hand_rig.rotation = lerp_angle(hand_rig.rotation, target, 1.0 - exp(-aim_speed * delta))


	var from_right := absf(wrapf(hand_rig.rotation, -PI, PI))
	if _aiming_left and from_right < PI * 0.5 - FLIP_DEADZONE:
		_aiming_left = false
	elif not _aiming_left and from_right > PI * 0.5 + FLIP_DEADZONE:
		_aiming_left = true

	if body_faces_mouse:
		body.flip_h = _aiming_left



func _apply_rig() -> void:
	body.scale = Vector2.ONE * body_scale
	hand_l.scale = Vector2.ONE * hand_scale
	hand_r.scale = Vector2.ONE * hand_scale
	hand_l.position = Vector2(hand_radius, -hand_separation)
	hand_r.position = Vector2(hand_radius, hand_separation)
