extends Node
class_name ArenaBounds

@export var locked_in := false
@export var snap := false
@export var inset := 48.0
@export var pull_speed := 10.0


func get_world_rect() -> Rect2:
	var camera := get_viewport().get_camera_2d()
	if camera == null:
		return Rect2()
	var size := (camera.get_viewport_rect().size / camera.zoom) + Vector2(80, 80)
	var center := camera.get_screen_center_position()
	return Rect2(center - size * 0.5, size).grow(-inset)


func apply(delta: float) -> void:
	var body := get_parent() as CharacterBody2D
	if body == null:
		return
	var rect := get_world_rect()
	if rect.size == Vector2.ZERO:
		return
	if not locked_in and rect.has_point(body.global_position):
		locked_in = true
	if not locked_in:
		return
	var clamped := body.global_position.clamp(rect.position, rect.end)
	if snap:
		body.global_position = clamped
	else:
		var t := 1.0 - exp(-pull_speed * delta)
		body.global_position = body.global_position.lerp(clamped, t)
	_cancel_outward(body, rect)


func _cancel_outward(body: CharacterBody2D, rect: Rect2) -> void:
	var pos := body.global_position
	if pos.x <= rect.position.x and body.velocity.x < 0.0:
		body.velocity.x = 0.0
	if pos.x >= rect.end.x and body.velocity.x > 0.0:
		body.velocity.x = 0.0
	if pos.y <= rect.position.y and body.velocity.y < 0.0:
		body.velocity.y = 0.0
	if pos.y >= rect.end.y and body.velocity.y > 0.0:
		body.velocity.y = 0.0
	if "knockback" in body:
		var kb: Vector2 = body.knockback
		if pos.x <= rect.position.x and kb.x < 0.0:
			kb.x = 0.0
		if pos.x >= rect.end.x and kb.x > 0.0:
			kb.x = 0.0
		if pos.y <= rect.position.y and kb.y < 0.0:
			kb.y = 0.0
		if pos.y >= rect.end.y and kb.y > 0.0:
			kb.y = 0.0
		body.knockback = kb
