extends Control

func _on_start_pressed() -> void:
	AudioManager.play_click()
	get_tree().change_scene_to_file("res://Scenes/world.tscn")

func _on_settings_pressed() -> void:
	AudioManager.play_click()

func _on_exit_pressed() -> void:
	AudioManager.play_click()
	await get_tree().create_timer(0.1).timeout 
	get_tree().quit()
