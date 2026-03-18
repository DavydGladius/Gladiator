extends Entity

var coincount: int = 0
@onready var footstep_audio = $FootstepPlayer
@onready var total_coins = $CanvasLayer/TextureRect/Label

func _ready():
	super._ready()
	add_to_group("player")
	died.connect(_on_player_died)
	
	if footstep_audio is AudioStreamPlayer2D:
		footstep_audio.max_distance = 2000

func _physics_process(_delta):
	if is_dead: return 
	var direction = Input.get_vector("left", "right", "up", "down")
	handle_movement(direction)

func _on_player_died():
	coincount = int(coincount * 0.9)
	if total_coins: total_coins.text = str(coincount)
	
	var wave_manager = get_tree().current_scene.find_child("WaveManager", true, false)
	if wave_manager:
		wave_manager.current_wavelvl = max(1, wave_manager.current_wavelvl - 1)
		wave_manager.stop_wave()
		wave_manager.clear_enemies()
	
	var death_screen = get_tree().current_scene.find_child("DeathScreen", true, false)
	if death_screen:
		death_screen.show_menu()

func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("coin"):
		coincount += area.collect()
		total_coins.text = str(coincount)
