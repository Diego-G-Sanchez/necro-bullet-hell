extends Control

const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"
const SHADER_WARMUP := preload("res://ui/shader_warmup.tscn")

@export var amount: int = 12
@export var pentagram_texture: Texture2D = preload("res://assets/pentagram.png")
@export var sprite_scale: float = 1.0
@export var spacing: float = 8.0

@onready var settings_panel: Control = %SettingsPage
@onready var master_slider: HSlider = %"Master Volume"
@onready var music_slider: HSlider = %Music
@onready var sfx_slider: HSlider = %SFX
@onready var play_button: Button = $PanelContainer/MarginContainer/VBoxContainer/Play
@onready var settings_button: Button = $PanelContainer/MarginContainer/VBoxContainer/Settings


func _on_play_button_up() -> void:
	#get_tree().change_scene_to_file("res://scenes/main.tscn")
	$Transition.fade_start()


func _ready() -> void:
	settings_panel.visible = false
	play_button.disabled = true
	settings_button.disabled = true
	_apply_starting_volume(master_slider, BUS_MASTER)
	_apply_starting_volume(music_slider, BUS_MUSIC)
	_apply_starting_volume(sfx_slider, BUS_SFX)
	_spawn_pentagrams()
	var warmup := SHADER_WARMUP.instantiate()
	add_child(warmup)
	await warmup.run()
	play_button.disabled = false
	settings_button.disabled = false


func _spawn_pentagrams() -> void:
	if amount <= 0 or pentagram_texture == null:
		return

	var layer := Node2D.new()
	layer.name = "Pentagrams"
	add_child(layer)
	move_child(layer, 0)

	var screen := get_viewport_rect().size
	var half := pentagram_texture.get_size() * 0.5 * sprite_scale
	var min_pos := Vector2(minf(half.x, screen.x * 0.5), minf(half.y, screen.y * 0.5))
	var max_pos := Vector2(maxf(screen.x - half.x, min_pos.x), maxf(screen.y - half.y, min_pos.y))
	var min_distance := half.length() * 2.0 + spacing
	var positions: Array[Vector2] = []

	for i in amount:
		var pos := _find_spaced_position(min_pos, max_pos, positions, min_distance)
		if pos == Vector2.INF:
			break
		positions.append(pos)

		var sprite := Sprite2D.new()
		sprite.texture = pentagram_texture
		sprite.position = pos
		sprite.rotation = randf() * TAU
		sprite.scale = Vector2.ONE * sprite_scale
		sprite.z_index = 1
		layer.add_child(sprite)


func _find_spaced_position(min_pos: Vector2, max_pos: Vector2, placed: Array[Vector2], min_distance: float) -> Vector2:
	const MAX_ATTEMPTS := 64
	for _attempt in MAX_ATTEMPTS:
		var candidate := Vector2(randf_range(min_pos.x, max_pos.x), randf_range(min_pos.y, max_pos.y))
		var far_enough := true
		for other in placed:
			if candidate.distance_to(other) < min_distance:
				far_enough = false
				break
		if far_enough:
			return candidate
	return Vector2.INF


func _on_settings_pressed() -> void:
	settings_panel.visible = true


func _on_master_volume_value_changed(value: float) -> void:
	_set_bus_from_slider(BUS_MASTER, value, master_slider.max_value)


func _on_music_value_changed(value: float) -> void:
	_set_bus_from_slider(BUS_MUSIC, value, music_slider.max_value)


func _on_sfx_value_changed(value: float) -> void:
	_set_bus_from_slider(BUS_SFX, value, sfx_slider.max_value)


func _on_button_pressed() -> void:
	settings_panel.visible = false


func _apply_starting_volume(slider: HSlider, bus_name: String) -> void:
	var half := slider.max_value * 0.5
	slider.set_value_no_signal(half)
	_set_bus_from_slider(bus_name, half, slider.max_value)


func _set_bus_from_slider(bus_name: String, value: float, max_value: float) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx < 0:
		return
	var linear := value / maxf(max_value, 1.0)
	AudioServer.set_bus_mute(bus_idx, linear <= 0.0)
	if linear > 0.0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear))
