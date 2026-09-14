extends Node
class_name GameState

@export var round_length: float = 100
@onready var round_timer: Timer = $RoundTimer
@export var trans: Transition 
@export var sm: ScoreManager
var _game_over_started := false

func _ready() -> void:
	Globals.reset_run_kills()
	round_timer.start(round_length)
	sm.game_lost.connect(game_over) # Call the game over function
	Globals.music.play()
	
func _on_round_timer_timeout() -> void:
	game_over()

func game_over():
	if _game_over_started:
		return
	_game_over_started = true
	Globals.final_score = int(sm.score)
	Globals.commit_run_kills()
	await Sfx.play(preload("res://sounds/sfx/deathtune.wav"),Vector2.ZERO, -20.0)
	trans.fade_start()
	#get_tree().change_scene_to_file("res://ui/game_over.tscn")
	
