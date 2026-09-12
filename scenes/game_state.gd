extends Node
class_name GameState

@export var round_length: float = 100
@onready var round_timer: Timer = $RoundTimer

@export var sm: ScoreManager 

func _ready() -> void:
	round_timer.start(round_length)
	sm.game_lost.connect(game_over) #Call the game over function
	
func _on_round_timer_timeout() -> void:
	game_over()

func game_over():
	Globals.final_score = int(sm.score)
	get_tree().change_scene_to_file("res://ui/game_over.tscn")
