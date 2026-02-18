extends CharacterBody2D


var movement_speed = 220.0


func _physics_process(delta: float) -> void:
	playermovement()

func playermovement():
	var direction = Input.get_vector("left","right","up","down")
	velocity = direction * movement_speed
	move_and_slide()
