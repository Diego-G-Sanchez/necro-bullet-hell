extends Control

@onready var score_label: Label = %Score

func _ready() -> void:
	if not Globals.music.playing:
		Globals.music.play()
	if Globals.final_score > 0: 
		score_label.text = 'Your Score: \n' + str(Globals.final_score)
	else:
		score_label.text = 'YOU LOST'
		
	#Ensure that any leftover enemies are cleared
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for e in enemies:
		e.queue_free()


func _on_button_button_up() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")
