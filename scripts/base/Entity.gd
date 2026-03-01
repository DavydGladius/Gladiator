extends CharacterBody2D
class_name Entity

@export var movement_speed: float = 100.0
@export var max_health: float = 100.0
@onready var animations: AnimatedSprite2D = $AnimatedSprite2D
@onready var healthBar = get_node("%HealthBar")

var current_health: float
var is_dead: bool = false

func _ready():
	current_health = max_health
	
	healthBar.max_value = max_health


func handle_movement(direction: Vector2):
	if is_dead: return # Jei miręs, nebejuda
	velocity = direction * movement_speed
	move_and_slide()
	update_animations(direction)

func update_animations(direction: Vector2):
	if is_dead: return
	
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
	healthBar.value = current_health
	print("Enemy hit! Health left: ", current_health) # PO TO PASALINTI
	
	if current_health <= 0:
		die()
	else:
		if animations.sprite_frames.has_animation("hurt_hit"):
			animations.play("hurt_hit")
			await animations.animation_finished
			if not is_dead:
				animations.play("idle")

func die():
	is_dead = true
	velocity = Vector2.ZERO
	animations.play("die")
	
	await animations.animation_finished 
	
	if is_in_group("player"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		queue_free()
