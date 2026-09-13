extends Node
class_name FrostEffect
@export var sprite:Node2D

var init_sprite_color: Color
var sf = 0
func apply(speed_factor, old_speed, slow_dur) -> void:
	sf = speed_factor
	init_sprite_color = sprite.self_modulate
	sprite.self_modulate = Color('58ffff')
	get_parent().speed *= sf
	$Timer.start(slow_dur)


func _on_timer_timeout() -> void:
	sprite.self_modulate = init_sprite_color
	get_parent().speed /= sf
