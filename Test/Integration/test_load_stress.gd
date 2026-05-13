extends "res://addons/gut/test.gd"

const WORLD_SCENE_PATH = "res://Scenes/world.tscn"
const ENEMY_SCENE_PATHS = [
	"res://characters/Enemy/enemy.tscn",
	"res://characters/Enemy/enemy_sword.tscn"
]
const SPAWN_POINTS = [
	"EnemySpawn/EnemySpawnDoor",
	"EnemySpawn/EnemySpawnHatch"
]
const DURATION_SECONDS = 180.0
const SPAWN_INTERVAL_SECONDS = 0.2
const METRIC_SAMPLE_SECONDS = 1.0

var world

func before_all():
	var world_scene = load(WORLD_SCENE_PATH)
	world = world_scene.instantiate()
	add_child(world)
	await get_tree().process_frame
	_make_player_invulnerable()
	var wave_manager = world.get_node_or_null("WaveManager")
	if wave_manager and wave_manager.has_method("stop_wave"):
		wave_manager.stop_wave()

func after_all():
	if world:
		world.queue_free()
		world = null

func test_load_spawn_for_3_minutes():
	if gut:
		gut.p("load_test duration_seconds=" + str(DURATION_SECONDS))
	else:
		print("load_test duration_seconds=", DURATION_SECONDS)
	var enemy_scenes: Array[PackedScene] = []
	for path in ENEMY_SCENE_PATHS:
		var scene = load(path)
		if scene:
			enemy_scenes.append(scene)
	assert_gt(enemy_scenes.size(), 0)

	var spawn_nodes: Array[Node2D] = []
	for node_path in SPAWN_POINTS:
		var spawn_node = world.get_node_or_null(node_path)
		if spawn_node:
			spawn_nodes.append(spawn_node)
	assert_gt(spawn_nodes.size(), 0)

	var start_ms = Time.get_ticks_msec()
	var duration_ms = int(DURATION_SECONDS * 1000.0)
	var next_spawn_ms = start_ms
	var last_sample_ms = start_ms
	var spawn_index = 0
	var total_spawned = 0
	var sample_count = 0
	var fps_sum = 0.0
	var process_sum = 0.0
	var mem_sum = 0.0
	var objects_sum = 0.0
	var enemies_sum = 0.0

	while Time.get_ticks_msec() - start_ms < duration_ms:
		var now_ms = Time.get_ticks_msec()
		if now_ms >= next_spawn_ms:
			_spawn_enemy(world, enemy_scenes, spawn_nodes, spawn_index)
			spawn_index += 1
			total_spawned += 1
			next_spawn_ms = now_ms + int(SPAWN_INTERVAL_SECONDS * 1000.0)
		if now_ms - last_sample_ms >= int(METRIC_SAMPLE_SECONDS * 1000.0):
			var metrics = _log_metrics(now_ms - start_ms, total_spawned)
			sample_count += 1
			fps_sum += metrics.fps
			process_sum += metrics.process_time
			mem_sum += metrics.mem
			objects_sum += metrics.object_count
			enemies_sum += metrics.enemies_alive
			last_sample_ms = now_ms
		await get_tree().process_frame

	var final_metrics = _log_metrics(Time.get_ticks_msec() - start_ms, total_spawned)
	sample_count += 1
	fps_sum += final_metrics.fps
	process_sum += final_metrics.process_time
	mem_sum += final_metrics.mem
	objects_sum += final_metrics.object_count
	enemies_sum += final_metrics.enemies_alive
	_log_summary(sample_count, fps_sum, process_sum, mem_sum, objects_sum, enemies_sum)
	assert_true(true)

func _spawn_enemy(world_node: Node, enemy_scenes: Array[PackedScene], spawn_nodes: Array[Node2D], spawn_index: int) -> void:
	var scene: PackedScene = enemy_scenes[spawn_index % enemy_scenes.size()]
	var enemy = scene.instantiate()
	enemy.add_to_group("enemies")
	var spawn_node: Node2D = spawn_nodes[spawn_index % spawn_nodes.size()]
	enemy.global_position = spawn_node.global_position
	world_node.add_child(enemy)

func _make_player_invulnerable() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	player.is_dead = false
	if "max_health" in player and "current_health" in player:
		player.current_health = player.max_health
	var collision = player.get_node_or_null("CollisionShape2D")
	if collision:
		collision.disabled = true
	if "collision_layer" in player:
		player.collision_layer = 0
	if "collision_mask" in player:
		player.collision_mask = 0

func _log_metrics(elapsed_ms: int, total_spawned: int) -> Dictionary:
	var fps = Performance.get_monitor(Performance.TIME_FPS)
	var process_time = Performance.get_monitor(Performance.TIME_PROCESS)
	var mem = Performance.get_monitor(Performance.MEMORY_STATIC)
	var object_count = Performance.get_monitor(Performance.OBJECT_COUNT)
	var enemies_alive = get_tree().get_nodes_in_group("enemies").size()
	var message = (
		"load_test elapsed_ms=" + str(elapsed_ms) +
		" spawned=" + str(total_spawned) +
		" alive=" + str(enemies_alive) +
		" fps=" + str(fps) +
		" proc_ms=" + str(process_time) +
		" mem_bytes=" + str(mem) +
		" objects=" + str(object_count)
	)
	if gut:
		gut.p(message)
	else:
		print(message)
	return {
		"fps": fps,
		"process_time": process_time,
		"mem": mem,
		"object_count": object_count,
		"enemies_alive": enemies_alive
	}

func _log_summary(sample_count: int, fps_sum: float, process_sum: float, mem_sum: float, objects_sum: float, enemies_sum: float) -> void:
	if sample_count <= 0:
		return
	var avg_fps = fps_sum / sample_count
	var avg_process = process_sum / sample_count
	var avg_mem = mem_sum / sample_count
	var avg_objects = objects_sum / sample_count
	var avg_enemies = enemies_sum / sample_count
	var summary = (
		"load_test avg samples=" + str(sample_count) +
		" avg_fps=" + str(avg_fps) +
		" avg_proc_ms=" + str(avg_process) +
		" avg_mem_bytes=" + str(avg_mem) +
		" avg_objects=" + str(avg_objects) +
		" avg_enemies=" + str(avg_enemies)
	)
	if gut:
		gut.p(summary)
	else:
		print(summary)
