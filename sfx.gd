extends Node

## Autoload for one-shot sound effects. Spawns a player, plays it, frees itself.
## Usage: Sfx.play(preload("res://sounds/sfx/whatever.wav"), global_position)
## Optional fade_out (seconds): if > 0, volume fades to silence over that duration.

## Returns the AudioStreamPlayer2D it spawned, in case the caller wants to hold
## onto it and stop it early (e.g. a charge-up loop that needs to cut off).
func play(stream: AudioStream, sound_position: Vector2 = Vector2.ZERO, volume_db: float = 0.0, fade_out: float = 0.0) -> AudioStreamPlayer2D:
	if stream == null:
		return null
	var player := AudioStreamPlayer2D.new()
	player.stream = stream
	player.bus = "SFX"
	player.volume_db = volume_db
	player.pitch_scale = randf_range(0.8, 1.3)
	player.position = sound_position
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
	if fade_out > 0.0:
		var tween := player.create_tween()
		tween.tween_property(player, "volume_db", -80.0, fade_out)
		tween.tween_callback(player.queue_free)
	return player
