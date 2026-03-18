extends Node2D

@export var enemy_scene: PackedScene   
@export var base_enemies_per_wave: int = 5
@export var base_spawn_interval: float = 1.5
@export var grace_period: float = 5.0

var current_wavelvl: int = 0
var total_spawned: int = 0
var spawn_timer: Timer
var grace_timer: Timer
var is_grace_period: bool = false

signal wave_started(wave: int, total_enemies: int)

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
	# Lygis padidinamas tik jei sėkmingai užbaigėme bangą. 
	# Jei ateiname čia po mirties, Player.gd jau bus pakeitęs current_wavelvl.
	current_wavelvl += 1 
	
	# Apskaičiuojame priešų kiekį šiai bangai
	var enemies_this_wave = base_enemies_per_wave + (current_wavelvl * 2)
	total_spawned = 0
	is_grace_period = false
	
	spawn_timer.start()
	emit_signal("wave_started", current_wavelvl, enemies_this_wave)
	print("Prasideda banga: ", current_wavelvl, " Priešų kiekis: ", enemies_this_wave)

func stop_wave():
	spawn_timer.stop()
	grace_timer.stop()

func _spawn_enemy():
	# Tikriname ar dar reikia spawinti
	var enemies_limit = base_enemies_per_wave + (current_wavelvl * 2)
	
	if total_spawned < enemies_limit:
		var enemy = enemy_scene.instantiate()
		# Naudojame global_position saugumui
		enemy.global_position = $"../EnemySpawn".global_position
		get_tree().current_scene.add_child(enemy)
		total_spawned += 1
	else:
		spawn_timer.stop()
		is_grace_period = true
		grace_timer.start()
