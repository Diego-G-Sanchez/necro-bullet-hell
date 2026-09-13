extends Control

const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"

@onready var settings_panel: Control = %SettingsPage
@onready var master_slider: HSlider = %"Master Volume"
@onready var music_slider: HSlider = %Music
@onready var sfx_slider: HSlider = %SFX


func _ready() -> void:
	visible = false
	settings_panel.visible = false
	_sync_slider_from_bus(master_slider, BUS_MASTER)
	_sync_slider_from_bus(music_slider, BUS_MUSIC)
	_sync_slider_from_bus(sfx_slider, BUS_SFX)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("pause"):
		return
	if settings_panel.visible:
		settings_panel.visible = false
		get_viewport().set_input_as_handled()
		return
	if get_tree().paused:
		_resume()
	else:
		_pause_game()
	get_viewport().set_input_as_handled()


func _on_resume_pressed() -> void:
	_resume()


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


func _pause_game() -> void:
	get_tree().paused = true
	visible = true


func _resume() -> void:
	settings_panel.visible = false
	visible = false
	get_tree().paused = false


func _sync_slider_from_bus(slider: HSlider, bus_name: String) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx < 0:
		return
	if AudioServer.is_bus_mute(bus_idx):
		slider.set_value_no_signal(0.0)
		return
	var linear := db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	slider.set_value_no_signal(linear * slider.max_value)


func _set_bus_from_slider(bus_name: String, value: float, max_value: float) -> void:
	var bus_idx := AudioServer.get_bus_index(bus_name)
	if bus_idx < 0:
		return
	var linear := value / maxf(max_value, 1.0)
	AudioServer.set_bus_mute(bus_idx, linear <= 0.0)
	if linear > 0.0:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(linear))
