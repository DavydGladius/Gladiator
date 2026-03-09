extends Entity

@onready var attack_area: Area2D = $AttackArea
@onready var footstep_audio: AudioStreamPlayer2D = $FootstepsEnemy
@onready var attack_sound: AudioStreamPlayer2D = $AttackSound
@onready var death_sound: AudioStreamPlayer2D = $DeathSound

@export var contact_damage: float = 10.0
@export var attack_cooldown_time: float = 1.0

var coin = preload("res://Scenes/coin.tscn")
var player_ref: Node2D
var can_attack: bool = true

func _ready():
	super._ready()
	player_ref = get_tree().get_first_node_in_group("player")
	
	# Connect signals
	died.connect(_on_enemy_died)
	died.connect(coindrop)
	
	if footstep_audio:
		footstep_audio.max_distance = 600

func take_damage(amount: float):
	if current_health - amount <= 0 and not is_dead:
		if death_sound:
			death_sound.pitch_scale = randf_range(0.9, 1.1)
			death_sound.play()
	
	super.take_damage(amount)

func _physics_process(_delta):
	if is_dead or not player_ref or player_ref.is_dead:
		velocity = Vector2.ZERO
		if footstep_audio.playing: 
			footstep_audio.stop()
		return

	var dist = global_position.distance_to(player_ref.global_position)
	
	if dist < 15: 
		velocity = Vector2.ZERO
		update_animations(Vector2.ZERO)
	else:
		var direction = global_position.direction_to(player_ref.global_position)
		handle_movement(direction)
	
	_handle_footstep_sounds()
	
	if can_attack:
		check_for_attacks()

func _handle_footstep_sounds():
	if velocity.length() > 5.0:
		if not footstep_audio.playing:
			footstep_audio.pitch_scale = randf_range(0.5, 0.7) 
			footstep_audio.play()
	else:
		footstep_audio.stop()

func check_for_attacks():
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			perform_attack(body)
			break

func perform_attack(target):
	can_attack = false
	if attack_sound:
		attack_sound.pitch_scale = randf_range(0.8, 1.1)
		attack_sound.play()
		
	target.take_damage(contact_damage)
	
	if is_inside_tree():
		await get_tree().create_timer(attack_cooldown_time).timeout
		can_attack = true

func _on_enemy_died():
	if footstep_audio: 
		footstep_audio.stop()
	
	if death_sound.playing:
		await death_sound.finished
	
	queue_free()

func coindrop():
	var coindroped = coin.instantiate()
	coindroped.global_position = global_position
	get_tree().current_scene.add_child(coindroped)
