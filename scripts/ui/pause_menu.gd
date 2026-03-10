extends Control

@onready var pause_panel = $Panel
@onready var settings_panel = $Settings # Ensure this path matches your scene tree!

func _ready():
	visible = false
	# Make sure settings starts hidden
	if settings_panel:
		settings_panel.visible = false

func Continue():
	AudioManager.play_click()
	get_tree().paused = false
	visible = false
	if $AudioStreamPlayer: $AudioStreamPlayer.stop()

func Pause():
	get_tree().paused = true
	visible = true
	# Always show the main pause buttons first when pausing
	pause_panel.show()
	if settings_panel: settings_panel.hide()
	if $AudioStreamPlayer: $AudioStreamPlayer.play()

func testEsc():
	if Input.is_action_just_pressed("Escape"):
		if !get_tree().paused:
			Pause()
		else:
			# If settings is open, close settings first instead of unpausing
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
	
	# Connect the signal if not already connected
	if not settings_panel.is_connected("closed", _on_settings_closed):
		settings_panel.connect("closed", _on_settings_closed)

func _on_settings_closed():
	# This runs when you click 'Back' in settings OR hit Escape while in settings
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
