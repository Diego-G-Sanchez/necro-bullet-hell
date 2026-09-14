class_name ControlsMenu
extends Button

const ACTION_LABELS := {
	"move_left": "Move Left",
	"move_right": "Move Right",
	"move_up": "Move Up",
	"move_down": "Move Down",
	"action1": "Primary Action",
	"action2": "Secondary Action",
	"go_wolf": "Wolf Hands",
	"go_sharp": "Sharp Hands",
	"go_mage": "Mage Hands",
	"pause": "Pause",
}

@onready var overlay: Control = %Overlay
@onready var bind_list: VBoxContainer = %BindList

var _bind_buttons: Dictionary = {}
var _listening_action: String = ""
var _ignore_activating_click: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pressed.connect(_on_controls_pressed)
	overlay.hide()
	overlay.set_as_top_level(true)
	_fit_overlay()
	get_viewport().size_changed.connect(_fit_overlay)
	_build_rows()


func is_overlay_open() -> bool:
	return overlay.visible


func close_overlay() -> void:
	_stop_listening()
	overlay.hide()


func _on_controls_pressed() -> void:
	overlay.show()
	_fit_overlay()
	_refresh_labels()
	move_to_front()


func _on_back_pressed() -> void:
	close_overlay()


func _on_reset_pressed() -> void:
	_stop_listening()
	Globals.reset_controls_to_defaults()
	_refresh_labels()


func _fit_overlay() -> void:
	overlay.position = Vector2.ZERO
	overlay.size = get_viewport_rect().size


func _build_rows() -> void:
	for child in bind_list.get_children():
		child.queue_free()
	_bind_buttons.clear()
	for action in Globals.REMAP_ACTIONS:
		var row := Panel.new()
		row.custom_minimum_size = Vector2(0, 28)
		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 8)
		var label := Label.new()
		label.text = str(ACTION_LABELS.get(action, action))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var bind_button := Button.new()
		bind_button.custom_minimum_size = Vector2(90, 0)
		bind_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		bind_button.pressed.connect(_on_bind_pressed.bind(action))
		hbox.add_child(label)
		hbox.add_child(bind_button)
		row.add_child(hbox)
		bind_list.add_child(row)
		hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		hbox.offset_left = 6
		hbox.offset_right = -6
		_bind_buttons[action] = bind_button
	_refresh_labels()


func _refresh_labels() -> void:
	for action in _bind_buttons:
		if action == _listening_action:
			continue
		var button: Button = _bind_buttons[action]
		var event := Globals.get_primary_event(action)
		button.text = Globals.format_input_event(event)


func _on_bind_pressed(action: String) -> void:
	if _listening_action == action:
		_stop_listening()
		_refresh_labels()
		return
	_start_listening(action)


func _start_listening(action: String) -> void:
	_listening_action = action
	_ignore_activating_click = true
	var button: Button = _bind_buttons[action]
	button.release_focus()
	button.text = "Press any key..."
	_refresh_labels()


func _stop_listening() -> void:
	_listening_action = ""
	_ignore_activating_click = false


func _input(event: InputEvent) -> void:
	if not overlay.visible:
		return
	if _listening_action.is_empty():
		if event.is_action_pressed("pause"):
			close_overlay()
			get_viewport().set_input_as_handled()
		return
	if _ignore_activating_click and event is InputEventMouseButton:
		if not event.pressed:
			_ignore_activating_click = false
		get_viewport().set_input_as_handled()
		return
	_ignore_activating_click = false
	if event is InputEventMouseButton and event.pressed:
		var hovered := get_viewport().gui_get_hovered_control()
		if hovered is Button and overlay.is_ancestor_of(hovered):
			return
	if not event.is_pressed() or event.is_echo():
		return
	if event is InputEventKey or event is InputEventMouseButton:
		Globals.replace_primary_event(_listening_action, _clean_bind_event(event))
		_stop_listening()
		_refresh_labels()
		get_viewport().set_input_as_handled()


func _clean_bind_event(event: InputEvent) -> InputEvent:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		var cleaned := InputEventKey.new()
		cleaned.physical_keycode = key_event.physical_keycode
		cleaned.keycode = key_event.keycode
		return cleaned
	if event is InputEventMouseButton:
		var cleaned := InputEventMouseButton.new()
		cleaned.button_index = (event as InputEventMouseButton).button_index
		return cleaned
	return event
