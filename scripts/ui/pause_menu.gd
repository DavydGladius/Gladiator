extends Control

func _ready():
	visible = false

func Continue():
	AudioManager.play_click()
	get_tree().paused = false
	visible = false
	if $AudioStreamPlayer: $AudioStreamPlayer.stop()

func Pause():
	get_tree().paused = true
	visible = true
	if $AudioStreamPlayer: $AudioStreamPlayer.play()

func testEsc():
	if Input.is_action_just_pressed("Escape"):
		if !get_tree().paused:
			Pause()
		else:
			Continue()

func _on_continue_pressed() -> void:
	Continue()

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
