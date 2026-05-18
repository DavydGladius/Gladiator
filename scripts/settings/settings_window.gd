extends Panel

signal closed

@onready var keybinds_box: VBoxContainer = $CenterContainer/InnerPanel/Scroll/VBoxLayout/KeybindsBox
@onready var keybind_warning: Label = $CenterContainer/InnerPanel/Scroll/VBoxLayout/KeybindWarning

var _listening_action: String = ""
var _listening_button: Button = null

const ANIM_DUR := 0.35

const ACTION_LABELS = {
	"up": "Move Up",
	"down": "Move Down",
	"left": "Move Left",
	"right": "Move Right",
	"bomb": "Bomb"
}

const ACTION_ORDER = ["up", "down", "left", "right", "bomb"]

const MODIFIER_KEYS = [KEY_SHIFT, KEY_CTRL, KEY_ALT, KEY_META, KEY_CAPSLOCK]

func _ready() -> void:
	modulate.a = 0.0
	_build_keybind_rows()

# Iškviečiama išorės (main_menu, pause_menu) kai nori animuotai uždaryti.
# Grąžina Tween kad galėtum await, tada emit closed.
func hide_animated() -> Tween:
	var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "modulate:a", 0.0, ANIM_DUR)
	tw.tween_callback(hide)
	return tw

func _on_back_pressed() -> void:
	AudioManager.play_click()
	var tw = hide_animated()
	await tw.finished
	closed.emit()

func _unhandled_input(event: InputEvent) -> void:
	if _listening_action == "" or not visible:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == 0:
			return
		if MODIFIER_KEYS.has(event.keycode):
			return
		var conflict = SettingsData.get_action_for_keycode(event.keycode, _listening_action)
		if conflict != "":
			_show_warning("Key is already bound to %s." % ACTION_LABELS.get(conflict, conflict))
			_restore_listening_button()
			get_viewport().set_input_as_handled()
			return
		SettingsData.set_keybind(_listening_action, event.keycode)
		_listening_button.text = _keycode_to_text(event.keycode)
		_listening_action = ""
		_listening_button = null
		keybind_warning.visible = false
		get_viewport().set_input_as_handled()

func _build_keybind_rows() -> void:
	for child in keybinds_box.get_children():
		child.queue_free()
	for action in ACTION_ORDER:
		var row = HBoxContainer.new()
		row.name = "%sRow" % action
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_theme_constant_override("separation", 16)

		var label = Label.new()
		label.custom_minimum_size = Vector2(200, 0)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_color_override("font_color", Color(0.95, 0.85, 0.55, 1))
		label.add_theme_font_size_override("font_size", 18)
		label.text = ACTION_LABELS.get(action, action)
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

		var button = Button.new()
		button.text = _keycode_to_text(SettingsData.get_keybind(action))
		button.pressed.connect(_on_rebind_pressed.bind(action, button))

		row.add_child(label)
		row.add_child(button)
		keybinds_box.add_child(row)

func _on_rebind_pressed(action: String, button: Button) -> void:
	AudioManager.play_click()
	if _listening_button != null and _listening_button != button:
		_restore_listening_button()
	_listening_action = action
	_listening_button = button
	_listening_button.text = "Press a key..."
	keybind_warning.visible = false

func _restore_listening_button() -> void:
	if _listening_button == null:
		return
	_listening_button.text = _keycode_to_text(SettingsData.get_keybind(_listening_action))
	_listening_action = ""
	_listening_button = null

func _show_warning(message: String) -> void:
	keybind_warning.text = message
	keybind_warning.visible = true

func _keycode_to_text(keycode: int) -> String:
	if keycode == 0:
		return "Unbound"
	return OS.get_keycode_string(keycode)
