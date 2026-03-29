extends "res://addons/gut/test.gd"

# =========================
# SETUP / TEARDOWN (5 punktas)
# =========================

var player

func before_each():
	# Sukuriamas Player objektas prieš kiekvieną testą
	player = preload("res://scripts/player/Player.gd").new()

	# Kadangi tavo kode health nėra inicializuojamas automatiškai
	player.max_health = 100
	player.current_health = player.max_health

	# Sukuriam dummy UI (kad @onready nesukeltų klaidų)
	if not player.has_node("CanvasLayer"):
		var dummy = Node.new()
		dummy.name = "CanvasLayer"
		player.add_child(dummy)

func after_each():
	# Sunaikinam objektą → kad nebūtų ORPHANS
	if player:
		player.queue_free()
	player = null


# =========================
# UNIT TESTAI (6 punktas)
# =========================

func test_player_created():
	# Tikrina ar objektas sukurtas
	assert_not_null(player)


func test_initial_health():
	# Tikrina ar pradinis health yra max
	assert_eq(player.current_health, player.max_health)


func test_take_damage_reduces_health():
	# Tikrina ar damage sumažina health
	var initial = player.current_health
	player.take_damage(10)
	assert_lt(player.current_health, initial)


func test_zero_damage():
	# EDGE CASE → 0 damage nieko nekeičia
	player.take_damage(0)
	assert_eq(player.current_health, player.max_health)


func test_multiple_hits():
	# Keli smūgiai iš eilės
	player.take_damage(10)
	player.take_damage(20)
	assert_eq(player.current_health, player.max_health - 30)


# =========================
# PARAMETRIZED TEST (4 punktas)
# =========================

func test_damage_values():
	# Testuojam su keliom reikšmėm
	var values = [5, 10, 20, 50]

	for dmg in values:
		player.current_health = player.max_health
		player.take_damage(dmg)

		assert_eq(player.current_health, player.max_health - dmg)


# =========================
# MOCK (3 punktas)
# =========================

class MockEnemy:
	func get_damage():
		return 15

func test_mock_enemy():
	# Fake objektas kuris grąžina damage
	var enemy = MockEnemy.new()

	player.current_health = player.max_health
	player.take_damage(enemy.get_damage())

	assert_eq(player.current_health, player.max_health - 15)


# =========================
# STUB (3 punktas)
# =========================

class StubEnemy:
	func get_damage():
		return 0

func test_stub_enemy():
	# Stub visada grąžina 0
	var enemy = StubEnemy.new()

	player.current_health = player.max_health
	player.take_damage(enemy.get_damage())

	assert_eq(player.current_health, player.max_health)
