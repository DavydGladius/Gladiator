extends Control

@onready var main_buttons: VBoxContainer = $MainButtons
@onready var settings: Panel = $Settings

func _ready():
	main_buttons.visible = true
	settings.visible = false

func _on_start_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_settings_pressed() -> void:
	AudioManager.play_click()
	settings.show()
	main_buttons.hide()
	if not settings.is_connected("closed", _on_settings_closed):
		settings.connect("closed", _on_settings_closed)

func _on_settings_closed():
	main_buttons.show()

func _on_exit_pressed() -> void:
	AudioManager.play_click()
	await get_tree().create_timer(0.1).timeout 
	get_tree().quit()


func _on_back_settings_pressed() -> void:
	AudioManager.play_click()
	_ready()
