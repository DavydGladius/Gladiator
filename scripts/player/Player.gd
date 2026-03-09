extends Entity

var coincount = 0

# 1. Ensure this points to an AudioStreamPlayer2D node
@onready var footstep_audio = $FootstepPlayer

@onready var total_coins = $CanvasLayer/TextureRect/Label

func _ready():
	super._ready()
	died.connect(_on_player_died)
	
	if footstep_audio is AudioStreamPlayer2D:
		footstep_audio.max_distance = 2000

func _physics_process(_delta):
	if is_dead: return 
	
	var direction = Input.get_vector("left", "right", "up", "down")
	handle_movement(direction)
	
	_handle_footstep_sounds()

func _handle_footstep_sounds():
	if velocity.length() > 5.0: 
		if not footstep_audio.playing:
			footstep_audio.pitch_scale = randf_range(0.6, 0.8)
			footstep_audio.play()

func _on_player_died():
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("coin"):
		coincount += area.collect()
		total_coins.text = str(coincount)
