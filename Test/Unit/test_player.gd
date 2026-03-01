extends GutTest

var Entity = preload("res://scripts/player/Player.gd")
var player : Entity

func before_each() -> void:
	player = Entity.new()
	add_child(player)
	await get_tree().process_frame

func after_each() -> void:
	player.queu_free()

func test_initial_health() -> void:
	assert_eq(player.current_health, player.max_health, "Entity should have max health.")
