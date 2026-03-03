extends StaticBody2D
class_name StaticEntity

@export var health: float = 20.0

func take_damage(amount: float):
	health -= amount
	if health <= 0:
		queue_free()
