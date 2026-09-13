extends Node

## Autoload for one-shot sound effects. Spawns a player, plays it, frees itself.
## Usage: Sfx.play(preload("res://sounds/sfx/whatever.wav"), global_position)

func play(stream: AudioStream, sound_position: Vector2 = Vector2.ZERO, volume_db: float = 0.0) -> void:
	if stream == null:
		return
	var player := AudioStreamPlayer2D.new()
	player.stream = stream
	player.bus = "SFX"
	player.volume_db = volume_db
	player.position = sound_position
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
