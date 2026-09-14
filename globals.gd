extends Node

const SAVE_PATH := "user://save.cfg"
const ENEMY_TYPES: Array[String] = ["zombie", "bat", "thiccums"]
const ENEMY_LABELS := {
	"zombie": "Zombies",
	"bat": "Bats",
	"thiccums": "Thiccums",
}

var final_score: int = 200
var high_score: int = 0
var has_high_score: bool = false

var run_kills: Dictionary = {}
var last_run_kills: Dictionary = {}
var best_kills: Dictionary = {}
var total_kills: Dictionary = {}

@onready var music: AudioStreamPlayer = $Music

func _ready() -> void:
	_empty_kill_maps()
	_load_save()

func _empty_kill_maps() -> void:
	run_kills = _zero_kills()
	last_run_kills = _zero_kills()
	best_kills = _zero_kills()
	total_kills = _zero_kills()

func _zero_kills() -> Dictionary:
	var kills := {}
	for enemy_type in ENEMY_TYPES:
		kills[enemy_type] = 0
	return kills

func _load_save() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	if cfg.has_section_key("save", "high_score"):
		high_score = int(cfg.get_value("save", "high_score", 0))
		has_high_score = true
	_load_kill_map(cfg, "kills_last_", last_run_kills)
	_load_kill_map(cfg, "kills_best_", best_kills)
	_load_kill_map(cfg, "kills_total_", total_kills)

func _load_kill_map(cfg: ConfigFile, prefix: String, target: Dictionary) -> void:
	for enemy_type in ENEMY_TYPES:
		var key := prefix + enemy_type
		if cfg.has_section_key("save", key):
			target[enemy_type] = int(cfg.get_value("save", key, 0))

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("save", "high_score", high_score)
	_write_kill_map(cfg, "kills_last_", last_run_kills)
	_write_kill_map(cfg, "kills_best_", best_kills)
	_write_kill_map(cfg, "kills_total_", total_kills)
	cfg.save(SAVE_PATH)

func _write_kill_map(cfg: ConfigFile, prefix: String, source: Dictionary) -> void:
	for enemy_type in ENEMY_TYPES:
		cfg.set_value("save", prefix + enemy_type, int(source.get(enemy_type, 0)))

func try_save_high_score(score: int) -> void:
	if score <= high_score:
		return
	high_score = score
	has_high_score = true
	_save()

func record_kill(enemy_type: String) -> void:
	if not run_kills.has(enemy_type):
		run_kills[enemy_type] = 0
	run_kills[enemy_type] = int(run_kills[enemy_type]) + 1

func reset_run_kills() -> void:
	run_kills = _zero_kills()

func commit_run_kills() -> void:
	for enemy_type in ENEMY_TYPES:
		var run_count := int(run_kills.get(enemy_type, 0))
		last_run_kills[enemy_type] = run_count
		best_kills[enemy_type] = maxi(int(best_kills.get(enemy_type, 0)), run_count)
		total_kills[enemy_type] = int(total_kills.get(enemy_type, 0)) + run_count
	_save()
