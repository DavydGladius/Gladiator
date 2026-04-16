extends Node2D

@export var enemy_scene: PackedScene
@export var base_enemies_per_wave: int = 5
@export var base_spawn_interval: float = 1.5
@export var grace_period: float = 5.0

var current_wavelvl: int = 0
var total_spawned: int = 0
var wave_finished_spawning: bool = false
var in_grace_period: bool = false
var grace_time_remaining: float = 0.0
var spawn_timer: Timer
var grace_timer: Timer
var progress_bar: ProgressBar
var wave_label: Label
signal wave_started(wave_number: int)


func _ready() -> void:
	await get_tree().process_frame
	progress_bar = get_tree().current_scene.find_child("WaveBar", true, false)
	wave_label = get_tree().current_scene.find_child("WaveLabel", true, false)
	_setup_timers()
	start_next_wave()

func _setup_timers():
	spawn_timer = Timer.new()
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_spawn_enemy)
	spawn_timer.wait_time = base_spawn_interval
	add_child(spawn_timer)

	grace_timer = Timer.new()
	grace_timer.one_shot = true
	grace_timer.wait_time = grace_period
	grace_timer.timeout.connect(start_next_wave)
	add_child(grace_timer)

func _set_bar_fill_color(color: Color) -> void:
	if not progress_bar:
		return
	var style = StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	progress_bar.add_theme_stylebox_override("fill", style)

func resume_grace_period():
	if in_grace_period:
		if grace_time_remaining > 0.0:
			grace_timer.wait_time = grace_time_remaining
			grace_timer.start()
		else:
			start_next_wave()

func start_next_wave():
	in_grace_period = false
	grace_time_remaining = 0.0
	grace_timer.wait_time = grace_period
	$"../SpawnGate/SpawnGateTop/AnimatedSprite2D".play("open")
	current_wavelvl += 1
	wave_started.emit(current_wavelvl) #for shop
	_heal_players()
	_run_spawning_logic()

func restart_current_wave():
	in_grace_period = false
	stop_wave()
	clear_enemies()
	$"../SpawnGate/SpawnGateTop/AnimatedSprite2D".play("open")
	_heal_players()
	_run_spawning_logic()

func clear_enemies():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.queue_free()
	print("Visi monstrai išvalyti.")

func _run_spawning_logic():
	var enemies_this_wave = base_enemies_per_wave + (current_wavelvl * 2)
	total_spawned = 0
	wave_finished_spawning = false
	spawn_timer.start()

	if progress_bar:
		progress_bar.max_value = enemies_this_wave
		progress_bar.value = enemies_this_wave
		_set_bar_fill_color(Color(0.8, 0.0, 0.0))

	if wave_label:
		wave_label.text = "Wave " + str(current_wavelvl)
		wave_label.modulate = Color.RED

	print("Prasideda banga: ", current_wavelvl, ". Priešų kiekis: ", enemies_this_wave)

func stop_wave():
	spawn_timer.stop()
	$"../SpawnGate/SpawnGateTop/AnimatedSprite2D".play("close")
	if not grace_timer.is_stopped():
		grace_time_remaining = grace_timer.time_left
	grace_timer.stop()

func _spawn_enemy():
	var enemies_limit = base_enemies_per_wave + (current_wavelvl * 2)
	if total_spawned < enemies_limit:
		if enemy_scene:
			var enemy = enemy_scene.instantiate()
			enemy.add_to_group("enemies")
			var spawn_pos = get_node_or_null("../EnemySpawn")
			enemy.global_position = spawn_pos.global_position if spawn_pos else global_position
			get_tree().current_scene.add_child(enemy)
			total_spawned += 1
	else:
		spawn_timer.stop()
		$"../SpawnGate/SpawnGateTop/AnimatedSprite2D".play("close")
		wave_finished_spawning = true

func _heal_players():
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		player.heal_full()

func _process(_delta):
	# Progress bar atvaizdavimas bangos metu
	if progress_bar and grace_timer.is_stopped():
		var enemies_alive = get_tree().get_nodes_in_group("enemies").size()
		var enemies_limit = base_enemies_per_wave + (current_wavelvl * 2)
		var remaining = enemies_alive + (enemies_limit - total_spawned)
		progress_bar.value = remaining

	# Tikriname, ar visi nužudyti, kad pradėtume Grace Period
	if wave_finished_spawning and grace_timer.is_stopped():
		var enemies_alive = get_tree().get_nodes_in_group("enemies").size()
		if enemies_alive == 0:
			wave_finished_spawning = false
			in_grace_period = true
			if progress_bar:
				progress_bar.max_value = grace_period
				progress_bar.value = grace_period
				_set_bar_fill_color(Color(0.0, 0.8, 0.0))
			if wave_label:
				wave_label.text = "Grace Period"
				wave_label.modulate = Color.GREEN
			print("Visi priešai nužudyti! Grace period prasideda...")
			grace_timer.start()

	# Progress bar atvaizdavimas Grace Period metu
	if not grace_timer.is_stopped() and progress_bar:
		progress_bar.value = grace_timer.time_left
