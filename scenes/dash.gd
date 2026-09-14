extends Area2D
class_name Dash

signal dash_started
signal dodged(area: Area2D)
signal iframes_ended

@export var player: Player
@export var hurt_box: Area2D
@export var body: CanvasItem

var _dash_frames_left: int = 0
var _iframes_left: int = 0
var _dash_velocity := Vector2.ZERO

## Sandevistan-style afterimage trail: one frozen, cyan-tinted ghost of the body
## sprite per physics frame while dashing, each fading out on its own.
const AFTERIMAGE_COLOR := Color(0.2, 0.95, 1.0, 0.55)
const AFTERIMAGE_FADE_TIME := 0.22

func _ready() -> void:
	monitoring = false
	area_entered.connect(_on_area_entered)

func is_dashing() -> bool:
	return _dash_frames_left > 0

func is_invulnerable() -> bool:
	return _iframes_left > 0

## Dash along the movement input secondary moujse input
func dash() -> void:
	var config := player.sm.config
	var dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir == Vector2.ZERO:
		dir = (player.get_aim_point() - player.global_position).normalized()
	_dash_velocity = dir * config.dash_speed
	_dash_frames_left = config.dash_frames
	start_iframes(config.dash_iframes)
	dash_started.emit()

## Turns the HurtBox off for a number of frames
func start_iframes(frames: int) -> void:
	_iframes_left = maxi(_iframes_left, frames)
	hurt_box.set_deferred("monitoring", false)
	set_deferred("monitoring", true)
	body.self_modulate.a = 0.4


func _physics_process(_delta: float) -> void:
	if _dash_frames_left > 0:
		_dash_frames_left -= 1
		player.velocity = _dash_velocity
		player.move_and_slide()
		_spawn_afterimage()

	if _iframes_left > 0:
		_iframes_left -= 1
		if _iframes_left == 0:
			hurt_box.set_deferred("monitoring", true)
			set_deferred("monitoring", false)
			body.self_modulate.a = 1.0
			iframes_ended.emit()

func _on_area_entered(area: Area2D) -> void:
	if is_invulnerable() and area.is_in_group("Enemy"):
		dodged.emit(area)

## Freezes a cyan ghost of the current body frame in place, then fades and
## slightly grows it before it deletes itself.
func _spawn_afterimage() -> void:
	var body_sprite := body as AnimatedSprite2D
	if body_sprite == null or body_sprite.sprite_frames == null:
		return

	var ghost := Sprite2D.new()
	ghost.texture = body_sprite.sprite_frames.get_frame_texture(body_sprite.animation, body_sprite.frame)
	ghost.global_transform = body_sprite.global_transform
	ghost.flip_h = body_sprite.flip_h
	ghost.modulate = AFTERIMAGE_COLOR
	ghost.z_index = body_sprite.z_index - 1
	get_tree().root.add_child(ghost)

	var tween := ghost.create_tween()
	tween.set_parallel(true)
	tween.tween_property(ghost, "modulate:a", 0.0, AFTERIMAGE_FADE_TIME)
	tween.tween_property(ghost, "scale", ghost.scale * 1.12, AFTERIMAGE_FADE_TIME)
	tween.finished.connect(ghost.queue_free)
