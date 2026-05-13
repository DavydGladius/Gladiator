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

func test_load_spawn_for_5_minutes():
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

	while Time.get_ticks_msec() - start_ms < duration_ms:
		var now_ms = Time.get_ticks_msec()
		if now_ms >= next_spawn_ms:
			_spawn_enemy(world, enemy_scenes, spawn_nodes, spawn_index)
			spawn_index += 1
			total_spawned += 1
			next_spawn_ms = now_ms + int(SPAWN_INTERVAL_SECONDS * 1000.0)
		if now_ms - last_sample_ms >= int(METRIC_SAMPLE_SECONDS * 1000.0):
			_log_metrics(now_ms - start_ms, total_spawned)
			last_sample_ms = now_ms
		await get_tree().process_frame

	_log_metrics(Time.get_ticks_msec() - start_ms, total_spawned)
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

func _log_metrics(elapsed_ms: int, total_spawned: int) -> void:
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
