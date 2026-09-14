extends Control

@onready var score_label: Label = %Score

var _music_restore_db: float = 0.0
var _paused_for_loss: bool = false

func _ready() -> void:
	if not Globals.music.playing:
		Globals.music.play()
	else:
		_paused_for_loss = true
		_music_restore_db = Globals.music.volume_db
		Globals.music.stream_paused = true
		Sfx.play(preload("res://sounds/sfx/deathtuneonly.wav"), Vector2.ZERO, 5.0,28.0)
		var fade := create_tween()
		fade.tween_interval(4.5)
		fade.tween_callback(func() -> void:
			Globals.music.volume_db = -80.0
			Globals.music.stream_paused = false
		)
		fade.tween_property(Globals.music, "volume_db", _music_restore_db, 2.0)
	var score_text := 'YOU LOST'
	if Globals.final_score > 0:
		$PanelContainer/MarginContainer/VBoxContainer/Label.text = "YOU WIN!"
		score_text = 'Your Score:\n' + str(Globals.final_score)
	if Globals.has_high_score:
		score_label.text = 'High Score: ' + str(Globals.high_score) + '\n' + score_text
	else:
		score_label.text = score_text
	Globals.try_save_high_score(Globals.final_score)
		
	#Ensure that any leftover enemies are cleared
	var enemies = get_tree().get_nodes_in_group("Enemy")
	for e in enemies:
		e.queue_free()


func _exit_tree() -> void:
	if not _paused_for_loss:
		return
	Globals.music.stream_paused = false
	Globals.music.volume_db = _music_restore_db


func _on_button_button_up() -> void:
	$Transition.fade_start()
	#get_tree().change_scene_to_file("res://scenes/main.tscn")
