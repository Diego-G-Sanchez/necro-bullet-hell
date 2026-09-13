extends Node
class_name WaveManager

@export var zombie: PackedScene
@export var bat: PackedScene
@export var camera: Camera2D
@export var zombie_weight: float = 0.8
@export var bat_cluster_min: int = 1
@export var bat_cluster_max: int = 5
@export var bat_cluster_spread: float = 48.0

func get_point_outside_camera() -> Vector2:
	var viewport_size = camera.get_viewport_rect().size / camera.zoom
	var half_size = viewport_size / 2.0
	
	# Pick a random angle
	var angle = randf() * TAU
	var dir = Vector2(cos(angle), sin(angle))
	
	# Push distance just past the screen edge (add extra margin pixels)
	var margin = 100.0
	var distance_x = half_size.x + margin
	var distance_y = half_size.y + margin
	
	# Scale direction vector anisotropically or use a safe radius
	var spawn_offset = Vector2(dir.x * distance_x, dir.y * distance_y)
	
	return camera.global_position + spawn_offset


func _on_timer_timeout() -> void:
	if randf() < zombie_weight:
		spawn_zombie()
	else:
		spawn_bat_cluster()


func spawn_zombie() -> void:
	var z = zombie.instantiate()
	z.global_position = get_point_outside_camera()
	get_tree().root.add_child(z)


func spawn_bat_cluster() -> void:
	var origin = get_point_outside_camera()
	var count = randi_range(bat_cluster_min, bat_cluster_max)
	#re roll if lots of bats. less likely to get more bats
	if count > bat_cluster_max/2 + 1:
		count = randi_range(bat_cluster_min, bat_cluster_max)
	for i in count:
		var b = bat.instantiate()
		b.global_position = origin + Vector2(
			randf_range(-bat_cluster_spread, bat_cluster_spread),
			randf_range(-bat_cluster_spread, bat_cluster_spread)
		)
		get_tree().root.add_child(b)
