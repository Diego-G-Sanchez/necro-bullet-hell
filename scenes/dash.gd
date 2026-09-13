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
