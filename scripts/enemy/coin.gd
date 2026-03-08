extends Area2D

@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound

var coin_value: int = 1

func collect():
	if pickup_sound:
		var root_node = get_tree().get_root()
		
		remove_child(pickup_sound)
		root_node.add_child(pickup_sound)
	
		pickup_sound.global_position = global_position
		
		pickup_sound.pitch_scale = randf_range(0.95, 1.1)
		pickup_sound.play()
		
		pickup_sound.finished.connect(pickup_sound.queue_free)
	
	queue_free()
	return coin_value
