extends Entity


func _physics_process(_delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	handle_movement(direction)
