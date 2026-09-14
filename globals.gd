extends Node

const SAVE_PATH := "user://save.cfg"
const REMAP_ACTIONS: Array[String] = [
	"move_left",
	"move_right",
	"move_up",
	"move_down",
	"action1",
	"action2",
	"go_wolf",
	"go_sharp",
	"go_mage",
	"pause",
]
const ENEMY_TYPES: Array[String] = ["zombie", "bat", "thiccums"]
const ENEMY_LABELS := {
	"zombie": "Zombies",
	"bat": "Bats",
	"thiccums": "Thiccums",
}

var final_score: int = 200
var high_score: int = 0
var has_high_score: bool = false

var run_kills: Dictionary = {}
var last_run_kills: Dictionary = {}
var best_kills: Dictionary = {}
var total_kills: Dictionary = {}
var _default_primaries: Dictionary = {}

@onready var music: AudioStreamPlayer = $Music

func _ready() -> void:
	_snapshot_default_primaries()
	_empty_kill_maps()
	_load_save()

func _empty_kill_maps() -> void:
	run_kills = _zero_kills()
	last_run_kills = _zero_kills()
	best_kills = _zero_kills()
	total_kills = _zero_kills()

func _zero_kills() -> Dictionary:
	var kills := {}
	for enemy_type in ENEMY_TYPES:
		kills[enemy_type] = 0
	return kills

func _load_save() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	if cfg.has_section_key("save", "high_score"):
		high_score = int(cfg.get_value("save", "high_score", 0))
		has_high_score = true
	_load_kill_map(cfg, "kills_last_", last_run_kills)
	_load_kill_map(cfg, "kills_best_", best_kills)
	_load_kill_map(cfg, "kills_total_", total_kills)
	_apply_controls_from_cfg(cfg)

func _load_kill_map(cfg: ConfigFile, prefix: String, target: Dictionary) -> void:
	for enemy_type in ENEMY_TYPES:
		var key := prefix + enemy_type
		if cfg.has_section_key("save", key):
			target[enemy_type] = int(cfg.get_value("save", key, 0))

func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	cfg.set_value("save", "high_score", high_score)
	_write_kill_map(cfg, "kills_last_", last_run_kills)
	_write_kill_map(cfg, "kills_best_", best_kills)
	_write_kill_map(cfg, "kills_total_", total_kills)
	_write_controls(cfg)
	cfg.save(SAVE_PATH)

func _write_kill_map(cfg: ConfigFile, prefix: String, source: Dictionary) -> void:
	for enemy_type in ENEMY_TYPES:
		cfg.set_value("save", prefix + enemy_type, int(source.get(enemy_type, 0)))


func _snapshot_default_primaries() -> void:
	_default_primaries.clear()
	for action in REMAP_ACTIONS:
		var event := get_primary_event(action)
		if event != null:
			_default_primaries[action] = serialize_input_event(event)


func _apply_controls_from_cfg(cfg: ConfigFile) -> void:
	for action in REMAP_ACTIONS:
		if not cfg.has_section_key("controls", action):
			continue
		var data: Variant = cfg.get_value("controls", action, {})
		if data is Dictionary:
			var event := deserialize_input_event(data)
			if event != null:
				replace_primary_event(action, event, false)


func _write_controls(cfg: ConfigFile) -> void:
	for action in REMAP_ACTIONS:
		var event := get_primary_event(action)
		if event == null:
			continue
		cfg.set_value("controls", action, serialize_input_event(event))


func _save_controls() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH)
	_write_controls(cfg)
	cfg.save(SAVE_PATH)


func get_primary_event(action: String) -> InputEvent:
	var events := InputMap.action_get_events(action)
	if events.is_empty():
		return null
	return events[0]


func format_input_event(event: InputEvent) -> String:
	if event is InputEventMouseButton:
		match (event as InputEventMouseButton).button_index:
			MOUSE_BUTTON_LEFT:
				return "LMB"
			MOUSE_BUTTON_RIGHT:
				return "RMB"
			MOUSE_BUTTON_MIDDLE:
				return "MMB"
			_:
				return "Mouse %d" % (event as InputEventMouseButton).button_index
	if event is InputEventKey:
		var key_event := event as InputEventKey
		var code := key_event.physical_keycode if key_event.physical_keycode != KEY_NONE else key_event.keycode
		return OS.get_keycode_string(code)
	if event == null:
		return "Unbound"
	return event.as_text()


func serialize_input_event(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		return {
			"type": "key",
			"physical_keycode": int(key_event.physical_keycode),
			"keycode": int(key_event.keycode),
		}
	if event is InputEventMouseButton:
		return {
			"type": "mouse",
			"button_index": int((event as InputEventMouseButton).button_index),
		}
	return {}


func deserialize_input_event(data: Dictionary) -> InputEvent:
	var event_type := str(data.get("type", ""))
	if event_type == "key":
		var key_event := InputEventKey.new()
		key_event.physical_keycode = int(data.get("physical_keycode", 0)) as Key
		key_event.keycode = int(data.get("keycode", 0)) as Key
		return key_event
	if event_type == "mouse":
		var mouse_event := InputEventMouseButton.new()
		mouse_event.button_index = int(data.get("button_index", 0)) as MouseButton
		return mouse_event
	return null


func events_match(a: InputEvent, b: InputEvent) -> bool:
	if a == null or b == null:
		return false
	if a is InputEventKey and b is InputEventKey:
		var a_key := a as InputEventKey
		var b_key := b as InputEventKey
		var a_code := a_key.physical_keycode if a_key.physical_keycode != KEY_NONE else a_key.keycode
		var b_code := b_key.physical_keycode if b_key.physical_keycode != KEY_NONE else b_key.keycode
		return a_code != KEY_NONE and a_code == b_code
	if a is InputEventMouseButton and b is InputEventMouseButton:
		return (a as InputEventMouseButton).button_index == (b as InputEventMouseButton).button_index
	return false


func replace_primary_event(action: String, new_event: InputEvent, persist: bool = true) -> void:
	if new_event == null or not InputMap.has_action(action):
		return
	if persist:
		_steal_primary(action, new_event)
	var events := InputMap.action_get_events(action)
	var rest: Array[InputEvent] = []
	for i in range(1, events.size()):
		rest.append(events[i])
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, new_event)
	for leftover in rest:
		if not events_match(leftover, new_event):
			InputMap.action_add_event(action, leftover)
	if persist:
		_save_controls()


func _steal_primary(except_action: String, new_event: InputEvent) -> void:
	for action in REMAP_ACTIONS:
		if action == except_action:
			continue
		var primary := get_primary_event(action)
		if events_match(primary, new_event):
			InputMap.action_erase_event(action, primary)


func reset_controls_to_defaults() -> void:
	for action in REMAP_ACTIONS:
		var data: Variant = _default_primaries.get(action, {})
		if data is Dictionary:
			var event := deserialize_input_event(data)
			if event != null:
				replace_primary_event(action, event, false)
	_save_controls()

func try_save_high_score(score: int) -> void:
	if score <= high_score:
		return
	high_score = score
	has_high_score = true
	_save()

func record_kill(enemy_type: String) -> void:
	if not run_kills.has(enemy_type):
		run_kills[enemy_type] = 0
	run_kills[enemy_type] = int(run_kills[enemy_type]) + 1

func reset_run_kills() -> void:
	run_kills = _zero_kills()

func commit_run_kills() -> void:
	for enemy_type in ENEMY_TYPES:
		var run_count := int(run_kills.get(enemy_type, 0))
		last_run_kills[enemy_type] = run_count
		best_kills[enemy_type] = maxi(int(best_kills.get(enemy_type, 0)), run_count)
		total_kills[enemy_type] = int(total_kills.get(enemy_type, 0)) + run_count
	_save()
