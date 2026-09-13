extends ColorRect
class_name Vignette

var alpha: float = 0.0
var _tween: Tween

func _ready() -> void:
	set_vignette_alpha(0.0)

func set_vignette_alpha(a: float) -> void:
	if not material is ShaderMaterial:
		return
	if _tween != null and _tween.is_running():
		return
	var target := clampf(a, 0.0, 0.25)
	_tween = create_tween()
	_tween.tween_method(_apply_alpha, alpha, target, 1.5)

func _apply_alpha(value: float) -> void:
	alpha = value
	material.set_shader_parameter("alpha", value)
