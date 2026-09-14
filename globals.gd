extends Node

const SAVE_PATH := "user://save.cfg"

var final_score: int = 200
var high_score: int = 0
var has_high_score: bool = false

@onready var music: AudioStreamPlayer = $Music

func _ready() -> void:
	_load_save()

func _load_save() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	if cfg.has_section_key("save", "high_score"):
		high_score = int(cfg.get_value("save", "high_score", 0))
		has_high_score = true

func try_save_high_score(score: int) -> void:
	if score <= high_score:
		return
	high_score = score
	has_high_score = true
	var cfg := ConfigFile.new()
	cfg.set_value("save", "high_score", high_score)
	cfg.save(SAVE_PATH)
