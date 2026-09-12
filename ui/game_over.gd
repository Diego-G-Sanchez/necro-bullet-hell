extends Control

@onready var score_label: Label = %Score

func _ready() -> void:
	if Globals.final_score > 0: 
		score_label.text = 'Your Score: \n' + str(Globals.final_score)
	else:
		score_label.text = 'YOU LOST'
