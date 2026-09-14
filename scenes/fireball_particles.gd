extends GPUParticles2D


func setup(bullet: Node) -> void:
	bullet.deleting.connect(_on_bullet_deleting)


func _on_bullet_deleting() -> void:
	reparent(get_tree().root)
	emitting = false
	await get_tree().create_timer(lifetime).timeout
	queue_free()
