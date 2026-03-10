extends HSlider

@export var audio_bus_name: String
var audio_bus_id: int

func _ready():
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	
	if audio_bus_name == "Music":
		value = SettingsData.music_volume
	else:
		value = SettingsData.sfx_volume

func _on_value_changed(v: float) -> void:
	if audio_bus_name == "Music":
		SettingsData.music_volume = v
	else:
		SettingsData.sfx_volume = v
		
	AudioServer.set_bus_volume_db(audio_bus_id, linear_to_db(v))
