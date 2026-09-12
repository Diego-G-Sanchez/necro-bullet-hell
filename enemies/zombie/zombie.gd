extends CharacterBody2D
class_name Zombie

@export var speed:float = 100.0
@export var acceleration:float = 50.0

var dir:= Vector2.ZERO
var player_ref: Player

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("Player")
	print(player_ref)
	
func _process(delta: float) -> void:
	if is_instance_valid(player_ref):
		dir = (player_ref.global_position - global_position).normalized()
		velocity = velocity.move_toward(dir * speed, acceleration * delta)
		
	move_and_slide()
		
