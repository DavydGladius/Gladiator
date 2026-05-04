extends Node

var music_volume: float = 1.0 
var sfx_volume: float = 1.0
var is_fullscreen: bool = false

const SETTINGS_SECTION = "settings"
const KEYBINDS_SECTION = "keybinds"
const ACTIONS = [
	"up",
	"down",
	"left",
	"right",
	"bomb"
]

var keybinds: Dictionary = {}

func _ready() -> void:
	_load_keybinds()
	_apply_keybinds()

func _load_keybinds() -> void:
	var data = SaveManager.load_section(SETTINGS_SECTION)
	var saved = data.get(KEYBINDS_SECTION, {})
	if saved is Dictionary and not saved.is_empty():
		keybinds = saved.duplicate(true)
	else:
		keybinds = _get_defaults_from_inputmap()
	_ensure_all_actions_present()
	_sanitize_duplicate_keybinds()

func _save_keybinds() -> void:
	var data = SaveManager.load_section(SETTINGS_SECTION)
	data[KEYBINDS_SECTION] = keybinds.duplicate(true)
	SaveManager.save_section(SETTINGS_SECTION, data)

func get_keybind(action: String) -> int:
	return int(keybinds.get(action, 0))

func set_keybind(action: String, keycode: int) -> void:
	keybinds[action] = int(keycode)
	_replace_key_event(action, int(keycode))
	_save_keybinds()

func get_action_for_keycode(keycode: int, ignore_action: String = "") -> String:
	for action in ACTIONS:
		if action == ignore_action:
			continue
		if int(keybinds.get(action, 0)) == keycode:
			return action
	return ""

func _get_defaults_from_inputmap() -> Dictionary:
	var defaults: Dictionary = {}
	for action in ACTIONS:
		var events = InputMap.action_get_events(action)
		var keycode := 0
		for event in events:
			if event is InputEventKey:
				keycode = event.keycode
				if keycode == 0:
					keycode = event.physical_keycode
				break
		if keycode != 0:
			defaults[action] = keycode
	return defaults

func _ensure_all_actions_present() -> void:
	for action in ACTIONS:
		if not keybinds.has(action):
			var fallback = _get_defaults_from_inputmap().get(action, 0)
			if int(fallback) != 0:
				keybinds[action] = int(fallback)

func _sanitize_duplicate_keybinds() -> void:
	var used: Dictionary = {}
	for action in ACTIONS:
		var keycode = int(keybinds.get(action, 0))
		if keycode == 0:
			continue
		if used.has(keycode):
			keybinds[action] = 0
		else:
			used[keycode] = true

func _apply_keybinds() -> void:
	for action in ACTIONS:
		var keycode = int(keybinds.get(action, 0))
		if keycode != 0:
			_replace_key_event(action, keycode)

func _replace_key_event(action: String, keycode: int) -> void:
	if keycode == 0:
		return
	var events = InputMap.action_get_events(action)
	for event in events:
		if event is InputEventKey:
			InputMap.action_erase_event(action, event)
	var new_event = InputEventKey.new()
	new_event.keycode = keycode
	InputMap.action_add_event(action, new_event)
