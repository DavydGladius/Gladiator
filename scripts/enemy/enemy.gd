extends Entity

@onready var player = get_tree().get_first_node_in_group("player")#Finds the player by global group


func _physics_process(_delta):
	var direction = global_position.direction_to(player.global_position)
	handle_movement(direction)
	
