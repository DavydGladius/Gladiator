extends Node2D

const SPEED: int = 800
@export var damage: float = 25.0

func _process(delta: float) -> void:
	position += transform.x * SPEED * delta

func _on_damage_area_body_entered(body: Node2D) -> void:
	# 1. Ignoruojam žaidėją
	if body.is_in_group("player") or body.name == "Player":
		return

	# 2. Damage priešui
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(get_full_damage())
		queue_free()
		return

	# 3. Atsitrenkimas į sienas/dekoracijas
	if body is TileMapLayer or body is StaticBody2D:
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
	
func get_full_damage():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		return damage * player.damage_multiplier
	return damage
