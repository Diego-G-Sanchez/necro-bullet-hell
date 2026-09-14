extends Label

func _ready() -> void:
	var lines := "Kills  run / best / all"
	for enemy_type in Globals.ENEMY_TYPES:
		var enemy_label: String = Globals.ENEMY_LABELS[enemy_type]
		var run_count := int(Globals.last_run_kills.get(enemy_type, 0))
		var best := int(Globals.best_kills.get(enemy_type, 0))
		var total := int(Globals.total_kills.get(enemy_type, 0))
		lines += "\n%s    %d / %d / %d" % [enemy_label, run_count, best, total]
	text = lines
