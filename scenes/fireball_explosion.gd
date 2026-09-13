extends Node2D
class_name Explosion

@export var hb: HitBox
var damage:int = 0
func start_explosion():
	$AnimationPlayer.play("boom")

	
func initialize(config: ScoreConfig):
	damage = config.mage_explosion_damage
	hb.set_damage(damage)

func _ready() -> void:
	start_explosion()
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "boom":
		queue_free()
