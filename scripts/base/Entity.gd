extends CharacterBody2D
class_name Entity

@export var movement_speed: float = 100.0
@export var max_health: int = 100
@onready var animations: AnimatedSprite2D = $AnimatedSprite2D

var current_health: int

func _ready():
	current_health = max_health

# A generic move function that both Players and Enemies can use
func handle_movement(direction: Vector2):
	velocity = direction * movement_speed
	move_and_slide()
	update_animations(direction)

func update_animations(direction: Vector2):
	if direction != Vector2.ZERO:
		animations.play("walk")
		animations.flip_h = direction.x < 0
	else:
		animations.play("idle")
