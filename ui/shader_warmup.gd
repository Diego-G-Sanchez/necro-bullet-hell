extends CanvasLayer

signal warmup_finished

static var completed: bool = false

const VIGNETTE_SHADER := preload("res://scenes/vignette.gdshader")
const HAND_SWAP := preload("res://scenes/hand_swap_particle.tscn")
const THICCUMS := preload("res://enemies/thiccums/thiccums.tscn")

@onready var status_label: Label = %Status
@onready var holder: Node2D = %Holder
@onready var ui: Control = $UI


func run() -> void:
	if completed:
		_finish()
		return
	await _draw_vignette()
	await _draw_hand_swap()
	await _draw_thiccums_particles()
	await _draw_fireball_light()
	await _draw_explosion_light()
	completed = true
	_finish()


func _finish() -> void:
	hide()
	warmup_finished.emit()
	queue_free()


func _wait_draw() -> void:
	await get_tree().process_frame
	await get_tree().process_frame


func _center() -> Vector2:
	return get_viewport().get_visible_rect().size * 0.5


func _draw_vignette() -> void:
	status_label.text = "Preparing shaders…"
	var rect := ColorRect.new()
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var mat := ShaderMaterial.new()
	mat.shader = VIGNETTE_SHADER
	mat.set_shader_parameter("alpha", 0.1)
	mat.set_shader_parameter("inner_radius", 0.0)
	mat.set_shader_parameter("outer_radius", 1.0)
	rect.material = mat
	ui.add_child(rect)
	ui.move_child(rect, 0)
	await _wait_draw()
	rect.queue_free()
	await get_tree().process_frame


func _draw_hand_swap() -> void:
	status_label.text = "Preparing particles…"
	var particles := HAND_SWAP.instantiate() as GPUParticles2D
	if particles.finished.is_connected(particles._on_finished):
		particles.finished.disconnect(particles._on_finished)
	particles.position = _center()
	holder.add_child(particles)
	particles.emitting = true
	particles.restart()
	await _wait_draw()
	particles.queue_free()
	await get_tree().process_frame


func _draw_thiccums_particles() -> void:
	status_label.text = "Preparing particles…"
	var enemy := THICCUMS.instantiate()
	var src := enemy.get_node("GPUParticles2D") as GPUParticles2D
	var particles := src.duplicate() as GPUParticles2D
	particles.position = _center()
	particles.emitting = true
	holder.add_child(particles)
	particles.restart()
	enemy.free()
	await _wait_draw()
	particles.queue_free()
	await get_tree().process_frame


func _draw_fireball_light() -> void:
	status_label.text = "Preparing lights…"
	var light := _make_point_light(Vector2(0.4, 0.4), 1.7)
	light.position = _center()
	holder.add_child(light)
	await _wait_draw()
	light.queue_free()
	await get_tree().process_frame


func _draw_explosion_light() -> void:
	status_label.text = "Preparing lights…"
	var light := _make_point_light(Vector2(1.71, 1.71), 2.8)
	light.position = _center()
	holder.add_child(light)
	await _wait_draw()
	light.queue_free()
	await get_tree().process_frame


func _make_point_light(light_scale: Vector2, energy: float) -> PointLight2D:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color(1, 1, 1, 1), Color(0, 0, 0, 1)])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(0.5, 0.0)
	var light := PointLight2D.new()
	light.scale = light_scale
	light.color = Color(0.70476854, 0, 0.18713072, 1)
	light.energy = energy
	light.texture = texture
	light.texture_scale = 1.87
	light.height = 100.0
	return light
