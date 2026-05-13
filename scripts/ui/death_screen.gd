extends Control

@onready var player = $"../../Player"

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
	var player_node = get_tree().get_first_node_in_group("player")
	if player_node:
		player_node.is_dead = false
		player_node.set_physics_process(true)
		player_node.current_health = player_node.max_health
		if player_node.health_bar:
			player_node.health_bar.value = player_node.current_health
		
		var collision = player_node.get_node_or_null("CollisionShape2D")
		if collision:
			collision.disabled = false
		
		if player_node.animations:
			player_node.animations.play("idle")

	# BANGOS RESTARTAS
	var wave_manager = get_tree().current_scene.find_child("WaveManager", true, false)
	if wave_manager:
		wave_manager.restart_current_wave()

func _on_end_button_pressed() -> void:
	AudioManager.play_click()
	await get_tree().create_timer(0.1).timeout 
	get_tree().quit()
