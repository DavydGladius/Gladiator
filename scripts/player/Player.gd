extends Entity

func _ready():
	super._ready()
	# Entity handled the animation, now we just change scenes
	died.connect(_on_player_died)

func _physics_process(_delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	handle_movement(direction)

func _on_player_died():
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
