extends Control

@onready var main_buttons: VBoxContainer = $MenuPanel/MainButtons
@onready var settings: Panel = $Settings
@onready var bg = $Background
@onready var overlay = $DarkOverlay
@onready var menu_panel = $MenuPanel

const FADE_DURATION   := 0.55
const SLIDE_DURATION  := 0.5
const SWITCH_OVERLAP  := 0.15

func _ready():
	main_buttons.visible = true
	settings.visible = false
	settings.modulate.a = 0.0
	# Įėjimas į meniu: fade-in iš juodo
	modulate.a = 0.0
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "modulate:a", 1.0, FADE_DURATION)

# ── Utility ─────────────────────────────────────────────────────────────────

func _fade_in(node: CanvasItem, dur: float = FADE_DURATION) -> void:
	node.visible = true
	node.modulate.a = 0.0
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tw.tween_property(node, "modulate:a", 1.0, dur)

func _fade_out(node: CanvasItem, dur: float = FADE_DURATION) -> Tween:
	var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tw.tween_property(node, "modulate:a", 0.0, dur)
	tw.tween_callback(node.hide)
	return tw

func _slide_in_from_right(node: CanvasItem, dur: float = SLIDE_DURATION) -> void:
	node.visible = true
	node.modulate.a = 0.0
	var orig_x = node.position.x
	node.position.x = orig_x + 40.0
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.set_parallel(true)
	tw.tween_property(node, "modulate:a", 1.0, dur)
	tw.tween_property(node, "position:x", orig_x, dur)

func _slide_out_to_left(node: CanvasItem, dur: float = SLIDE_DURATION) -> Tween:
	var orig_x = node.position.x
	var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tw.set_parallel(true)
	tw.tween_property(node, "modulate:a", 0.0, dur)
	tw.tween_property(node, "position:x", orig_x - 40.0, dur)
	tw.chain().tween_callback(func():
		node.position.x = orig_x
		node.hide()
	)
	return tw

func _slide_in_from_left(node: CanvasItem, dur: float = SLIDE_DURATION) -> void:
	node.visible = true
	node.modulate.a = 0.0
	var orig_x = node.position.x
	node.position.x = orig_x - 40.0
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.set_parallel(true)
	tw.tween_property(node, "modulate:a", 1.0, dur)
	tw.tween_property(node, "position:x", orig_x, dur)

# ── Mygtukai ────────────────────────────────────────────────────────────────

func _on_start_pressed() -> void:
	Global.load_save = false
	AudioManager.play_click()
	var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	await tw.finished
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_load_pressed() -> void:
	Global.load_save = true
	AudioManager.play_click()
	var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "modulate:a", 0.0, 0.5)
	await tw.finished
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_settings_pressed() -> void:
	AudioManager.play_click()
	_slide_out_to_left(menu_panel)
	_fade_out(bg, FADE_DURATION * 0.6)
	_fade_out(overlay, FADE_DURATION * 0.6)
	# Settings atsiranda po slide animacijos
	await get_tree().create_timer(SLIDE_DURATION - SWITCH_OVERLAP).timeout
	# Paprastas fade-in - NE scale, nes Settings yra full-screen Panel
	# ir scale < 1 atskleistų pilką Godot foną kraštuose
	_fade_in(settings, FADE_DURATION * 0.7)
	if not settings.is_connected("closed", _on_settings_closed):
		settings.connect("closed", _on_settings_closed)

func _on_settings_closed():
	# Settings jau hide'inamas pačio settings_window.gd per hide_animated()
	# Tiesiog parodom menu atgal
	_fade_in(bg, FADE_DURATION * 0.6)
	_fade_in(overlay, FADE_DURATION * 0.6)
	_slide_in_from_left(menu_panel)

func _on_back_settings_pressed() -> void:
	AudioManager.play_click()
	_on_settings_closed()

func _on_exit_pressed() -> void:
	AudioManager.play_click()
	var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tw.tween_property(self, "modulate:a", 0.0, 0.45)
	await tw.finished
	get_tree().quit()
