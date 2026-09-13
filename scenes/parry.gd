extends Area2D

func parry():
	var areas = get_overlapping_areas()
	var bullets = areas.filter(func(node): return node.is_in_group("Bullet"))
	
	for i in bullets:
		i.queue_free()
