extends Node2D

@export var enemy_scene: PackedScene   
@export var base_enemies_per_wave: int = 5
@export var base_spawn_interval: float = 1.5
@export var grace_period: float = 5.0

var current_wavelvl: int = 0
var total_spawned: int = 0
var spawn_timer: Timer
var grace_timer: Timer

func _ready() -> void:
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

func start_next_wave():
	current_wavelvl += 1 
	_run_spawning_logic()

func restart_current_wave():
	clear_enemies()
	_run_spawning_logic()

func clear_enemies():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.queue_free()
	print("Visi monstrai išvalyti.")

func _run_spawning_logic():
	var enemies_this_wave = base_enemies_per_wave + (current_wavelvl * 2)
	total_spawned = 0
	spawn_timer.start()
	print("Prasideda banga: ", current_wavelvl, ". Priešų kiekis: ", enemies_this_wave)

func stop_wave():
	spawn_timer.stop()
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
		grace_timer.start()
