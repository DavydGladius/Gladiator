extends Node2D

@export var enemy_scene: PackedScene   
@export var base_enemies_per_wave: int
@export var base_spawn_interval: float
@export var grace_period: float
var current_wavelvl: int = 0
var total_spawned: int = 0
var spawn_timer: Timer
var grace_timer: Timer
var is_grace_period: bool = false

signal wave_started(wave: int, level: int)
signal grace_period_started(seconds: float)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_timers()
	
	start_next_wave()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
	grace_timer.stop()

func start_next_wave():
	current_wavelvl += 1
	base_enemies_per_wave += current_wavelvl + 1
	total_spawned = 0
	spawn_timer.start()

func _spawn_enemy():
	var enemy = enemy_scene.instantiate()
	enemy.global_position = $"../EnemySpawn".position

	get_tree().current_scene.add_child(enemy)
	total_spawned += 1
	if(base_enemies_per_wave == total_spawned):
		spawn_timer.stop()
		is_grace_period = true
		print(is_grace_period)
		grace_timer.start()
