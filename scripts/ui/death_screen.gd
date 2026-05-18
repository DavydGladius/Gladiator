extends Control

@onready var player = $"../../Player"

const FADE_IN_DUR  := 0.55
const FADE_OUT_DUR := 0.4

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	modulate.a = 0.0
	scale = Vector2(1.0, 1.0)
	if $AudioStreamPlayer: $AudioStreamPlayer.stop()

func show_menu():
	show()
	get_tree().paused = true
	if $AudioStreamPlayer: $AudioStreamPlayer.play()
	modulate.a = 0.0
	scale = Vector2(0.92, 0.92)
	pivot_offset = size * 0.5
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tw.set_parallel(true)
	tw.tween_property(self, "modulate:a", 1.0, FADE_IN_DUR)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), FADE_IN_DUR * 0.8)

func _on_continue_button_pressed() -> void:
	AudioManager.play_click()
	pivot_offset = size * 0.5
	var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
	tw.set_parallel(true)
	tw.tween_property(self, "modulate:a", 0.0, FADE_OUT_DUR)
	tw.tween_property(self, "scale", Vector2(0.95, 0.95), FADE_OUT_DUR)
	await tw.finished

	get_tree().paused = false
	hide()
	scale = Vector2(1.0, 1.0)
	if $AudioStreamPlayer: $AudioStreamPlayer.stop()

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

	var wave_manager = get_tree().current_scene.find_child("WaveManager", true, false)
	if wave_manager:
		wave_manager.restart_current_wave()

func _on_end_button_pressed() -> void:
	AudioManager.play_click()
	# Naudojam TransitionLayer fade to black - arena neturi matytis
	var tl = get_tree().current_scene.get_node_or_null("TransitionLayer")
	if tl:
		var black = ColorRect.new()
		black.color = Color(0, 0, 0, 0)
		black.mouse_filter = Control.MOUSE_FILTER_IGNORE
		black.set_anchors_preset(Control.PRESET_FULL_RECT)
		tl.add_child(black)
		var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		tw.tween_property(black, "color:a", 1.0, 0.45)
		await tw.finished
	else:
		var tw = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SINE)
		tw.tween_property(self, "modulate:a", 0.0, 0.45)
		await tw.finished
	get_tree().paused = false
	get_tree().quit()
