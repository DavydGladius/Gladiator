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

var enemies_to_spawn_this_wave: int = 0 
var mini_bosses_to_spawn: int = 0          
var mini_bosses_spawned: int = 0

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
	$"../SpawnGate/SpawnHatch/AnimatedSprite2D".play("open")
	current_wavelvl += 1
	_heal_players()
	_run_spawning_logic()

func restart_current_wave():
	in_grace_period = false
	stop_wave()
	clear_enemies()
	$"../SpawnGate/SpawnGateTop/AnimatedSprite2D".play("open")
	$"../SpawnGate/SpawnHatch/AnimatedSprite2D".play("open")
	_heal_players()
	_run_spawning_logic()

func clear_enemies():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.queue_free()
	print("Visi monstrai išvalyti.")

func _run_spawning_logic():
	var base_count = base_enemies_per_wave + (current_wavelvl * 2)
	total_spawned = 0
	mini_bosses_spawned = 0
	wave_finished_spawning = false
	
	if current_wavelvl % 5 == 0:
		enemies_to_spawn_this_wave = int(base_count / 2.0) # Pusė mažiau paprastų
		mini_bosses_to_spawn = 1
		if current_wavelvl >= 20: mini_bosses_to_spawn = 2 # Nuo 20 bangos - 2 bosai
	else:
		enemies_to_spawn_this_wave = base_count
		mini_bosses_to_spawn = 0
	spawn_timer.start()
	if progress_bar:
		var total_this_wave = enemies_to_spawn_this_wave + mini_bosses_to_spawn
		progress_bar.max_value = total_this_wave # Nustatome naują baro "ilgį"
		progress_bar.value = total_this_wave     # Iškart užpildome iki galo
		_set_bar_fill_color(Color(0.8, 0.0, 0.0))
	if wave_label:
		wave_label.text = "Wave " + str(current_wavelvl)
		wave_label.modulate = Color.RED

	print("Prasideda banga: ", current_wavelvl)

func stop_wave():
	spawn_timer.stop()
	$"../SpawnGate/SpawnGateTop/AnimatedSprite2D".play("close")
	$"../SpawnGate/SpawnHatch/AnimatedSprite2D".play("close")
	if not grace_timer.is_stopped():
		grace_time_remaining = grace_timer.time_left
	grace_timer.stop()

func _spawn_enemy():
	# 1. Pirmiausia spawniname paprastus priešus
	if total_spawned < enemies_to_spawn_this_wave:
		_instantiate_enemy(false)
		total_spawned += 1
	# 2. Kai paprasti baigiasi, spawniname bosus
	elif mini_bosses_spawned < mini_bosses_to_spawn:
		_instantiate_enemy(true)
		mini_bosses_spawned += 1
	# 3. Kai viskas baigta - uždarom vartus
	else:
		spawn_timer.stop()
		$"../SpawnGate/SpawnGateTop/AnimatedSprite2D".play("close")
		$"../SpawnGate/SpawnHatch/AnimatedSprite2D".play("close")
		wave_finished_spawning = true

func _instantiate_enemy(is_mini_boss: bool):
	var scene = sword_enemy_scene if (total_spawned % 2 == 1) else enemy_scene
	var enemy = scene.instantiate()
	enemy.add_to_group("enemies")

	if is_mini_boss:
		enemy.scale = Vector2(1.6, 1.6)
		var health_vars = ["health", "hp", "max_health", "current_health"]
		for v in health_vars:
			if v in enemy:
				enemy.set(v, enemy.get(v) * 3.0)
		if "damage" in enemy:
			enemy.damage *= 1.5
		if "money_drop" in enemy:
			enemy.money_drop = 5
		enemy.modulate = Color(1.5, 0.5, 0.5)
	var spawn_points = ["../EnemySpawn/EnemySpawnDoor", "../EnemySpawn/EnemySpawnHatch"]
	var spawn_pos = get_node_or_null(spawn_points[randi() % spawn_points.size()])
	enemy.global_position = spawn_pos.global_position if spawn_pos else global_position
	
	get_tree().current_scene.add_child(enemy)
	
func _heal_players():
	var players = get_tree().get_nodes_in_group("player")
	for player in players:
		player.heal_full()

func _process(_delta):
	# Skaičiuojame progresą tik kovos metu
	if progress_bar and grace_timer.is_stopped() and not in_grace_period:
		var enemies_alive = 0
		# Skaičiuojame tik tuos, kurie dar gyvi ir neištrinti
		for e in get_tree().get_nodes_in_group("enemies"):
			if not e.is_queued_for_deletion():
				enemies_alive += 1
		
		# Kiek dar liko sukurti šioje bangoje
		var still_to_spawn = (enemies_to_spawn_this_wave - total_spawned) + (mini_bosses_to_spawn - mini_bosses_spawned)
		
		# Galutinė vertė: gyvi ekrane + tie, kurie dar atsiras
		progress_bar.value = enemies_alive + still_to_spawn

	# Grace period (laikas tarp bangų)
	if wave_finished_spawning and grace_timer.is_stopped():
		var alive_now = 0
		for e in get_tree().get_nodes_in_group("enemies"):
			if not e.is_queued_for_deletion():
				alive_now += 1
				
		if alive_now == 0:
			wave_finished_spawning = false
			in_grace_period = true
			if progress_bar:
				progress_bar.max_value = grace_period
				progress_bar.value = grace_period
				_set_bar_fill_color(Color(0.0, 0.8, 0.0))
			if wave_label:
				wave_label.text = "Grace Period"
				wave_label.modulate = Color.GREEN
			wave_started.emit(current_wavelvl)
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
