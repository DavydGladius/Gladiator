extends GutTest # No "class_name" here!

# We use the Scene so all nodes (%HealthBar, AnimatedSprite2D) exist
var PlayerScene = preload("res://characters/Player/player.tscn") 
var player  # This will now correctly reference your Player.gd class

func before_each() -> void:
	player = PlayerScene.instantiate()
	add_child_autofree(player)
	# Wait for _ready() to complete so nodes are initialized
	await get_tree().process_frame

func test_take_damage_reduces_health() -> void:
	var initial_health = player.current_health
	var damage = 20.0
	
	player.take_damage(damage)
	
	assert_eq(player.current_health, initial_health - damage, "Health should decrease by the damage amount.")

func test_health_bar_updates_on_damage() -> void:
	player.take_damage(50.0)
	# Using 'assert_almost_eq' is safer for float comparisons
	assert_almost_eq(player.healthBar.value, player.current_health, 0.01, "The health bar value should match current_health.")

func test_death_logic() -> void:
	player.take_damage(player.max_health + 10.0)
	assert_true(player.is_dead, "Player should be flagged as dead.")
