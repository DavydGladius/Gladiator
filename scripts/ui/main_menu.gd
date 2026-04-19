extends Control

@onready var main_buttons: VBoxContainer = $MenuPanel/MainButtons
@onready var settings: Panel = $Settings
@onready var bg = $Background
@onready var overlay = $DarkOverlay
@onready var menu_panel = $MenuPanel

func _ready():
	main_buttons.visible = true
	settings.visible = false

func _on_start_pressed() -> void:
	Global.load_save = false
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_settings_pressed() -> void:
	AudioManager.play_click()
	# Paslėpti meniu panelį ir foną kad nesidubliuotų su settings fonu
	menu_panel.hide()
	bg.hide()
	overlay.hide()
	settings.show()
	if not settings.is_connected("closed", _on_settings_closed):
		settings.connect("closed", _on_settings_closed)

func _on_settings_closed():
	settings.hide()
	menu_panel.show()
	bg.show()
	overlay.show()

func _on_exit_pressed() -> void:
	AudioManager.play_click()
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()

func _on_back_settings_pressed() -> void:
	AudioManager.play_click()
	_ready()

func _on_load_pressed() -> void:
	Global.load_save = true
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://Scenes/world.tscn")
