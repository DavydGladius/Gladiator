extends Entity # This gives us movement_speed, animations, and health!

func _physics_process(_delta):
	# The Player's unique job is just gathering Input
	var direction = Input.get_vector("left", "right", "up", "down")
	
	# Use the function from the Parent (Entity)
	handle_movement(direction)
