extends Control
class_name Transition
@export var next_scene: String


func _ready() -> void:
	fade_end()
	
func fade_start():
	visible =true
	$AnimationPlayer.play("FadeStart")
	
func fade_end():
	$AnimationPlayer.play("FadeEnd")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "FadeStart":
		get_tree().change_scene_to_file(next_scene)
	if anim_name =="FadeEnd":
		visible = false

#res://scenes/main.tscn
