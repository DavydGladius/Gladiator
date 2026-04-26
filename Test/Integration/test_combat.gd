extends "res://addons/gut/test.gd"

# =========================
# INTEGRATION TESTAI (7 punktas)
# =========================

var player
var enemy

func before_each():
	player = preload("res://scripts/player/Player.gd").new()
	enemy = preload("res://scripts/enemy/enemy.gd").new()

	player.max_health = 100
	player.current_health = 100

	enemy.max_health = 100
	enemy.current_health = 100

func after_each():
	if player:
		player.queue_free()
	if enemy:
		enemy.queue_free()
	player = null
	enemy = null


func test_player_damages_enemy():
	var initial = enemy.current_health

	enemy.take_damage(10)

	assert_lt(enemy.current_health, initial)


func test_enemy_damages_player():
	var initial = player.current_health

	player.take_damage(10)

	assert_lt(player.current_health, initial)


func test_combat_exchange():
	# Simuliuojam kovą rankiniu būdu
	player.take_damage(10)
	enemy.take_damage(20)

	assert_true(player.current_health < 100)
	assert_true(enemy.current_health < 100)
