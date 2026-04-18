extends Control

@onready var pause_panel = $Panel
@onready var settings_panel = $Settings
@onready var player = $"../../Player"
@onready var wavemanager = $"../../WaveManager"

func _ready():
	visible = false
	if settings_panel:
		settings_panel.visible = false

func _get_shop_canvas() -> CanvasLayer:
	var safe_area = get_tree().current_scene.find_child("SafeArea", true, false)
	if safe_area:
		return safe_area.get_node_or_null("CanvasLayer")
	return null

func Continue():
	AudioManager.play_click()
	get_tree().paused = false
	visible = false
	if $AudioStreamPlayer: $AudioStreamPlayer.stop()
	# Parodyti shop atgal jei žaidėjas yra safe area
	var canvas = _get_shop_canvas()
	if canvas:
		var safe_area = get_tree().current_scene.find_child("SafeArea", true, false)
		if safe_area and safe_area.get_overlapping_bodies().any(func(b): return b.is_in_group("player")):
			canvas.visible = true

func Pause():
	get_tree().paused = true
	visible = true
	pause_panel.show()
	if settings_panel: settings_panel.hide()
	if $AudioStreamPlayer: $AudioStreamPlayer.play()
	# Paslėpti shop kai pause
	var canvas = _get_shop_canvas()
	if canvas:
		canvas.visible = false

func testEsc():
	if Input.is_action_just_pressed("Escape"):
		if !get_tree().paused:
			Pause()
		else:
			if settings_panel and settings_panel.visible:
				_on_settings_closed()
			else:
				Continue()

func _on_continue_pressed() -> void:
	Continue()

func _on_settings_pressed() -> void:
	AudioManager.play_click()
	pause_panel.hide()
	settings_panel.show()
	if not settings_panel.is_connected("closed", _on_settings_closed):
		settings_panel.connect("closed", _on_settings_closed)

func _on_settings_closed():
	settings_panel.hide()
	pause_panel.show()

func _on_main_menu_pressed() -> void:
	AudioManager.play_click()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_exit_pressed() -> void:
	AudioManager.play_click()
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()

func _process(_delta):
	testEsc()

func _on_save_pressed() -> void:
	player.save_player_data()
	wavemanager.save_wave_data()

func _on_load_pressed() -> void:
	player.load_player_data()
	wavemanager.load_wave_data()
	var shop = get_tree().current_scene.find_child("ShopScene", true, false)
	if shop and shop.has_method("load_shop_from_save"):
		shop.load_shop_from_save()
