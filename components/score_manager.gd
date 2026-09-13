extends Node
class_name ScoreManager

@export var p: Player
@export var config: ScoreConfig

@onready var popup = preload("res://ui/score_popup.tscn")

var score := 0.0

signal game_lost

func _ready() -> void:
	score = config.init_score

func _process(delta: float) -> void:
	if p.hand_state == p.Hands.Wolf:
		score -= delta * config.drain_per_second

	if score <= 0:
		game_lost.emit()
	
	var danger_threshold := config.init_score / config.percent_of_score_left_to_show_vignette
	var vignette := $"../CanvasLayer/Vignette"
	if score < danger_threshold:
		vignette.set_vignette_alpha(get_inv_alpha(score, danger_threshold))
	else:
		vignette.set_vignette_alpha(0.0)

func get_inv_alpha(value: float, max_val: float) -> float:
	if max_val <= 0.0:
		return 1.0
	var clamped := clampf(value, 0.0, max_val)
	return 1.0 - (clamped / max_val)

func change_score(score_diff: float, gpos: Vector2):
	score += score_diff
	var p = popup.instantiate() as ScorePopup
	p.global_position = gpos
	get_tree().root.add_child(p)
	p.set_score_value(score_diff)
