extends Control

@onready var pause_panel = $Panel
@onready var settings_panel = $Settings
@onready var player = $"../../Player"
@onready var wavemanager = $"../../WaveManager"
@onready var bg = $Background
@onready var overlay = $DarkOverlay

const FADE_DURATION  := 0.45
const SLIDE_DURATION := 0.4
const SWITCH_OVERLAP := 0.12

func _get_player_hud() -> CanvasLayer:
	var p = get_tree().current_scene.find_child("Player", true, false)
	if p:
		return p.get_node_or_null("CanvasLayer")
	return null

func _get_shop_canvas() -> CanvasLayer:
	var safe_area = get_tree().current_scene.find_child("SafeArea", true, false)
	if safe_area:
		return safe_area.get_node_or_null("CanvasLayer")
	return null

# Fade to black per TransitionLayer (layer=128, virš visko), tada callback
func _fade_to_black_then(callback: Callable) -> void:
	var tl = get_tree().current_scene.get_node_or_null("TransitionLayer")
	if tl:
		var black = ColorRect.new()
		black.color = Color(0, 0, 0, 0)
		black.mouse_filter = Control.MOUSE_FILTER_IGNORE
		black.set_anchors_preset(15)
		tl.add_child(black)
		var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		tw.tween_property(black, "color:a", 1.0, 0.45)
		await tw.finished
	callback.call()

func _ready():
	visible = false
	if settings_panel:
		settings_panel.visible = false
		settings_panel.modulate.a = 0.0
	bg.modulate.a = 0.0
	overlay.modulate.a = 0.0

# ── Utility ──────────────────────────────────────────────────────────────────

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

func _slide_in_up(node: CanvasItem, dur: float = SLIDE_DURATION) -> void:
	node.visible = true
	node.modulate.a = 0.0
	var orig_y = node.position.y
	node.position.y = orig_y + 28.0
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.set_parallel(true)
	tw.tween_property(node, "modulate:a", 1.0, dur)
	tw.tween_property(node, "position:y", orig_y, dur)

func _slide_out_down(node: CanvasItem, dur: float = SLIDE_DURATION) -> Tween:
	var orig_y = node.position.y
	var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tw.set_parallel(true)
	tw.tween_property(node, "modulate:a", 0.0, dur)
	tw.tween_property(node, "position:y", orig_y + 28.0, dur)
	tw.chain().tween_callback(func():
		node.position.y = orig_y
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

# ── Pause / Continue ─────────────────────────────────────────────────────────

func Pause():
	get_tree().paused = true
	visible = true
	modulate.a = 1.0
	if settings_panel: settings_panel.hide()
	if $AudioStreamPlayer: $AudioStreamPlayer.play()
	var hud = _get_player_hud()
	if hud: hud.visible = false
	var canvas = _get_shop_canvas()
	if canvas: canvas.visible = false
	bg.visible = true
	bg.modulate.a = 0.0
	overlay.visible = true
	overlay.modulate.a = 0.0
	var tw_bg = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tw_bg.tween_property(bg, "modulate:a", 1.0, FADE_DURATION * 0.7)
	var tw_ov = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tw_ov.tween_property(overlay, "modulate:a", 1.0, FADE_DURATION * 0.7)
	await get_tree().create_timer(FADE_DURATION * 0.15).timeout
	_slide_in_up(pause_panel)

func Continue():
	AudioManager.play_click()
	_slide_out_down(pause_panel)
	await get_tree().create_timer(SLIDE_DURATION - SWITCH_OVERLAP).timeout
	_fade_out(bg, FADE_DURATION * 0.6)
	_fade_out(overlay, FADE_DURATION * 0.6)
	await get_tree().create_timer(FADE_DURATION * 0.6).timeout
	get_tree().paused = false
	visible = false
	if $AudioStreamPlayer: $AudioStreamPlayer.stop()
	var hud = _get_player_hud()
	if hud: hud.visible = true
	var canvas = _get_shop_canvas()
	if canvas:
		var safe_area = get_tree().current_scene.find_child("SafeArea", true, false)
		if safe_area and safe_area.get_overlapping_bodies().any(func(b): return b.is_in_group("player")):
			canvas.visible = true

func testEsc():
	if Input.is_action_just_pressed("Escape"):
		if not get_tree().paused:
			Pause()
		else:
			if settings_panel and settings_panel.visible:
				_on_settings_closed()
			else:
				Continue()

# ── Mygtukai ─────────────────────────────────────────────────────────────────

func _on_continue_pressed() -> void:
	Continue()

func _on_settings_pressed() -> void:
	AudioManager.play_click()
	# bg ir overlay NESLĖPIAM - jie dengia areną. Settings turi savo foną.
	_slide_out_to_left(pause_panel)
	await get_tree().create_timer(SLIDE_DURATION - SWITCH_OVERLAP).timeout
	_fade_in(settings_panel, FADE_DURATION * 0.7)
	if not settings_panel.is_connected("closed", _on_settings_closed):
		settings_panel.connect("closed", _on_settings_closed)

func _on_settings_closed():
	# bg ir overlay jau matomi, tiesiog grąžinam pause_panel
	await get_tree().create_timer(FADE_DURATION * 0.1).timeout
	_slide_in_from_left(pause_panel)

func _on_main_menu_pressed() -> void:
	AudioManager.play_click()
	await _fade_to_black_then(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	)

func _on_exit_pressed() -> void:
	AudioManager.play_click()
	await _fade_to_black_then(func():
		get_tree().paused = false
		get_tree().quit()
	)

func _process(_delta):
	testEsc()

func _on_save_pressed() -> void:
	player.save_player_data()
	wavemanager.save_wave_data()
