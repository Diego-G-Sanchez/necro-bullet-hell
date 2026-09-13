extends Control
class_name ScorePopup

@onready var label = %Label
@export var green: Color
@export var red: Color

func set_score_value(val: int):
	if val > 0:
		label.add_theme_color_override("font_color", green)
		label.text = '+' + str(int(val))
	else:
		label.add_theme_color_override("font_color", red)
		label.text = '-' + str(int(val))
	rotation_degrees = randf_range(-20, 20)
	
	run_tweens()
	
func run_tweens():
	var scale_tween = create_tween()
	scale_tween.tween_property(self, 'scale', Vector2(.5, .5), .4)
	var alpha_tween = create_tween()
	alpha_tween.tween_property(self, 'modulate:a', 0, .4)
	var y_tween = create_tween()
	y_tween.tween_property(self, 'global_position:y', -100, .4).as_relative()
	var x_tween = create_tween()
	x_tween.tween_property(self, 'global_position:x', randf_range(-20, 20), .4).as_relative()
	scale_tween.tween_callback(queue_free)
