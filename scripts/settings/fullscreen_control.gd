extends CheckButton

func _ready():
	button_pressed = SettingsData.is_fullscreen

func _on_toggled(toggled_on: bool) -> void:
	SettingsData.is_fullscreen = toggled_on
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
