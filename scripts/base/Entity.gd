extends CharacterBody2D
class_name Entity

signal died

@export var movement_speed: float = 100.0
@export var max_health: float = 100.0

@onready var animations = get_node_or_null("AnimatedSprite2D")
@onready var health_bar = get_node_or_null("%HealthBar")

var current_health: float
var is_dead: bool = false

func _ready():
	current_health = max_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health

func handle_movement(direction: Vector2):
	if is_dead: return
	if direction.length() > 0:
		direction = direction.normalized()
	velocity = direction * movement_speed
	move_and_slide()
	update_animations(direction)

func update_animations(direction: Vector2):
	if not animations or is_dead: return 
	if animations.animation == "hurt_hit" and animations.is_playing():
		return
	if direction != Vector2.ZERO:
		animations.play("walk")
		animations.flip_h = direction.x < 0
	else:
		animations.play("idle")

func take_damage(amount: float):
	if is_dead: return
	current_health -= amount
	if health_bar: health_bar.value = current_health
	
	if current_health <= 0:
		die()
	elif animations and animations.sprite_frames.has_animation("hurt_hit"):
		animations.play("hurt_hit")

func die():
	if is_dead: return
	is_dead = true
	
	velocity = Vector2.ZERO
	set_physics_process(false)
	
	var collision = get_node_or_null("CollisionShape2D")
	if collision:
		collision.set_deferred("disabled", true)
	
	if animations and animations.sprite_frames.has_animation("die"):
		animations.play("die")
		await animations.animation_finished
	
	died.emit()
