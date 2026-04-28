extends Node2D

@export var enemy_scene: PackedScene
@export var sword_enemy_scene: PackedScene
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

	print("Prasideda banga: ", current_wavelvl)

func stop_wave():
	spawn_timer.stop()
	$"../SpawnGate/SpawnGateTop/AnimatedSprite2D".play("close")
	if not grace_timer.is_stopped():
		grace_time_remaining = grace_timer.time_left
	grace_timer.stop()

func _spawn_enemy():
	var enemies_limit = base_enemies_per_wave + (current_wavelvl * 2)
	if total_spawned < enemies_limit:
		var scene_to_spawn
		if total_spawned % 2 == 1 and sword_enemy_scene:
			scene_to_spawn = sword_enemy_scene
		else:
			scene_to_spawn = enemy_scene
			
		if scene_to_spawn:
			var enemy = scene_to_spawn.instantiate()
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
	if progress_bar and grace_timer.is_stopped():
		var enemies_alive = get_tree().get_nodes_in_group("enemies").size()
		var enemies_limit = base_enemies_per_wave + (current_wavelvl * 2)
		var remaining = enemies_alive + (enemies_limit - total_spawned)
		progress_bar.value = remaining

	# Grace period pradžia — čia emituojame wave_started šopui atsinaujinti
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
			print("Grace period prasideda, shopas atsinaujina...")
			wave_started.emit(current_wavelvl)  # Shopas atsinaujina grace period metu
			grace_timer.start()

	if not grace_timer.is_stopped() and progress_bar:
		progress_bar.value = grace_timer.time_left

func _get_resume_wave_level() -> int:
	# If saved during grace, that wave is already cleared, so resume at next one.
	var resume_wave = current_wavelvl
	if in_grace_period:
		resume_wave += 1
	return max(1, resume_wave)

func save_wave_data() -> void:
	SaveManager.save_section("wave", {
		"current_wavelvl": current_wavelvl,
		"resume_wavelvl": _get_resume_wave_level()
	})

func load_wave_data() -> void:
	var d = SaveManager.load_section("wave")
	if d.is_empty():
		return
	current_wavelvl = max(1, int(d.get("resume_wavelvl", d.get("current_wavelvl", 1))))
	restart_current_wave()

func first_load_wave_data() -> void:
	var d = SaveManager.load_section("wave")
	if d.is_empty():
		return
	current_wavelvl = max(0, int(d.get("resume_wavelvl", d.get("current_wavelvl", 1))) - 1)
