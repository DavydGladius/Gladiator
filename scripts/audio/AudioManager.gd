extends Node

var click_sound = preload("res://assets/sound_effects/Menu_Selection_Click.wav") 

func play_click():
	var player = AudioStreamPlayer.new()
	add_child(player)
	
	player.stream = click_sound
	
	player.volume_db = -10.0 
	
	player.bus = "SFX"
	player.process_mode = Node.PROCESS_MODE_ALWAYS 
	
	player.pitch_scale = randf_range(0.95, 1.05)
	
	player.play()
	
	player.finished.connect(player.queue_free)
