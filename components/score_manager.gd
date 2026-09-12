extends Node
class_name ScoreManager

@export var p: Player

@export var init_score: float

@export_category("Score Costs")
@export_group("Wolf")
@export var drain_per_second:float = 1.0
@export var slash_cost:float = 1.0
@export var parry_cost:float = 1.0
@export var wolf_swap_cost:float = 10.0

@export_group("Sharp")
@export var shot_cost:float = 1.0
@export var shot_hit_reward_mult: float = 1.5
@export var dash_cost:float = 1.0
@export var sharp_swap_cost:float = 10.0

@export_group("Mage")
@export var frost_cost:float = 1.0
@export var fire_ball_cost:float = 10.0
@export var mage_swap_cost:float = 10.0
var score := 0.0

signal game_lost

func _ready() -> void:
	score = init_score

func _process(delta: float) -> void:
	if p.hand_state == p.Hands.Wolf:
		score -= delta * drain_per_second

	if score <= 0:
		game_lost.emit()
