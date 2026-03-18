extends Entity

var coincount:int = 0

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
	# 1. Pinigų praradimas (10%)
	coincount = int(coincount * 0.9)
	total_coins.text = str(coincount)
	
	# 2. Bangos lygio mažinimas
	var wave_manager = get_parent().get_node("WaveManager")
	if wave_manager:
		# Sumažiname per 1, bet neleidžiame nukristi žemiau 0
		wave_manager.current_wavelvl = max(0, wave_manager.current_wavelvl - 1)
		wave_manager.stop_wave() # Sustabdome spawinimą kol esame mirties ekrane
	
	# 3. Mirties ekrano rodymas
	var death_screen = get_parent().get_node("CanvasLayer/DeathScreen")
	if death_screen:
		death_screen.show_menu()
	else:
		print("Mirei. Pinigai: ", coincount)
		
func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("coin"):
		coincount += area.collect()
		total_coins.text = str(coincount)
