extends Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if $AudioStreamPlayer: $AudioStreamPlayer.stop()

func show_menu():
	show()
	get_tree().paused = true
	if $AudioStreamPlayer: $AudioStreamPlayer.play()

func _on_continue_button_pressed() -> void:
	AudioManager.play_click()
	get_tree().paused = false
	hide()
	if $AudioStreamPlayer: $AudioStreamPlayer.stop()
	
	# ŽAIDĖJO PRIKĖLIMAS
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_dead = false
		player.set_physics_process(true)
		player.current_health = player.max_health
		if player.health_bar:
			player.health_bar.value = player.current_health
		
		var collision = player.get_node_or_null("CollisionShape2D")
		if collision:
			collision.disabled = false
		
		if player.animations:
			player.animations.play("idle")

	# BANGOS RESTARTAS
	var wave_manager = get_tree().current_scene.find_child("WaveManager", true, false)
	if wave_manager:
		wave_manager.restart_current_wave()

func _on_end_button_pressed() -> void:
	AudioManager.play_click()
	get_tree().quit()
