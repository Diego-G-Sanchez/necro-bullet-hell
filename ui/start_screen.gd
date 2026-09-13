extends Control

const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"

@onready var settings_panel: Control = %SettingsPage
@onready var master_slider: HSlider = %"Master Volume"
@onready var music_slider: HSlider = %Music
@onready var sfx_slider: HSlider = %SFX


func _on_play_button_up() -> void:
	#get_tree().change_scene_to_file("res://scenes/main.tscn")
	$Transition.fade_start()


func _ready() -> void:
	settings_panel.visible = false
	_apply_starting_volume(master_slider, BUS_MASTER)
	_apply_starting_volume(music_slider, BUS_MUSIC)
	_apply_starting_volume(sfx_slider, BUS_SFX)


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
