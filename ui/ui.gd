extends Control

@onready var time_label = %Time
@onready var score_label =%Score

@export var gs: GameState
@export var sm: ScoreManager

func _process(delta: float) -> void:
	if gs.round_timer:
		time_label.text = str(gs.round_timer.time_left).left(4)
		
	if sm.score:
		score_label.text = str(int(sm.score))
