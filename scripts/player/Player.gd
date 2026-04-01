extends Entity

var coincount: int = 0
@onready var footstep_audio = $FootstepPlayer
@onready var total_coins = $CanvasLayer/TextureRect/Label

@onready var sword = $BasicSword
@onready var bow = $BasicBow

@export var bomb_scene: PackedScene # Nepamiršk įtempti Bomb.tscn inspektoriuje!
@export var throw_force: float = 600.0

var damage_multiplier: float = 1.0
var speed_multiplier: float = 1.0
var health_bonus: float = 0.0

func _ready():
	super._ready()
	add_to_group("player")
	died.connect(_on_player_died)
	
	if footstep_audio is AudioStreamPlayer2D:
		footstep_audio.max_distance = 2000
	
	switch_weapon("sword")

func _physics_process(_delta):
	if is_dead: return 
	var direction = Input.get_vector("left", "right", "up", "down")
	handle_movement(direction)
	
	if Input.is_action_just_pressed("bomb"):
		throw_bomb()
	#====================================================
	#		CIA TIKTAIS TRUMPAM ATEITYJE ISTRINTI
	#====================================================
	
	if Input.is_action_just_pressed("weapon1"):
		switch_weapon("sword")
		
	if Input.is_action_just_pressed("weapon2"):
		switch_weapon("bow")
		
	#====================================================
	#====================================================

# ŠIĄ FUNKCIJĄ KVIETI IŠ SHOP: player.switch_weapon("bow") ATEICIAI
func switch_weapon(weapon_type: String):
	if weapon_type == "sword":
		sword.show()
		sword.process_mode = PROCESS_MODE_INHERIT
		bow.hide()
		bow.process_mode = PROCESS_MODE_DISABLED
	elif weapon_type == "bow":
		bow.show()
		bow.process_mode = PROCESS_MODE_INHERIT
		sword.hide()
		sword.process_mode = PROCESS_MODE_DISABLED
		
func throw_bomb():
	if not bomb_scene:
		print("KLAIDA: Nepamiršk įtempti Bomb.tscn į inspektorių!")
		return

	# 1. Sukuriame bombos scenos instanciją
	var b = bomb_scene.instantiate()
	
	# 2. PRIDEDAME į sceną (rekomenduojama į current_scene, kad nejudėtų su žaidėju)
	get_tree().current_scene.add_child(b)
	
	# 3. POZICIJA: Nustatome pagrindinio mazgo poziciją į žaidėjo poziciją
	b.global_position = global_position
	
	# 4. SURANDAME RigidBody2D:
	# Tikriname patį b arba jo vaiką "Explosive"
	var rb: RigidBody2D = null
	if b is RigidBody2D:
		rb = b
	else:
		# Ieškome vaiko pavadinimu "Explosive", kuris turi būti RigidBody2D
		rb = b.get_node_or_null("Explosive")
	
	# 5. METIMAS:
	if rb:
		# Užtikriname, kad vaiko globali pozicija irgi būtų teisinga (jei b nėra RB)
		if rb != b:
			rb.global_position = global_position
			
		var dir = (get_global_mouse_position() - global_position).normalized()
		
		# Išvalome senus greičius (saugumo dėlei)
		rb.linear_velocity = Vector2.ZERO
		# Metame!
		rb.apply_central_impulse(dir * throw_force)
		print("Bomba sėkmingai išmesta!")
	else:
		print("KLAIDA: Bombos scenoje (arba vaike 'Explosive') nerastas RigidBody2D!")
	
func _on_player_died():
	coincount = round(float(coincount * 0.9))
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
