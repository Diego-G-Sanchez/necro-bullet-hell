extends Area2D

@export var player: Player

signal bullets_parried(count: int)

func parry():
	var areas = get_overlapping_areas()
	var bullets = areas.filter(func(node): return node.is_in_group("Bullet"))

	var reward: float = player.sm.config.parry_points_per_bullet
	for i in bullets:
		player.sm.change_score(reward, i.global_position)
		var b = i.get_parent()
		b.delete_bullet()

	if bullets.size() > 0:
		bullets_parried.emit(bullets.size())
