extends CharacterBody2D

@export var movement_speed = 100
@onready var animations = $AnimatedSprite2D

func _physics_process(_delta):
	player_movement()

func player_movement():

	var direction = Input.get_vector("left", "right", "up", "down")
	
	velocity = direction * movement_speed
	move_and_slide()
	
	update_animations(direction)

func update_animations(direction):
	if direction != Vector2.ZERO:
		animations.play("walk")
		
		if direction.x > 0:
			animations.flip_h = false
		elif direction.x < 0:
			animations.flip_h = true
	else:
		animations.play("idle")
