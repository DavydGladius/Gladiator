extends Node2D

const ARROW = preload("res://characters/weapons/Arrow.tscn")
@onready var muzzle: Marker2D = $Marker2D
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound


var can_shoot: bool = true
@export var shoot_cooldown: float = 0.5

func _process(_delta: float) -> void:

	if not is_visible_in_tree(): return

	look_at(get_global_mouse_position())
	
	rotation_degrees = wrap(rotation_degrees, 0, 360)
	if rotation_degrees > 90 and rotation_degrees < 270:
		scale.y = -1
	else:
		scale.y = 1
		
	if Input.is_action_just_pressed("shoot"):
		shoot_sound.play()
		shoot()

func shoot():
	if not can_shoot:
		return
	
	can_shoot = false
	var arrow_instance = ARROW.instantiate()
	get_tree().current_scene.add_child(arrow_instance)
	arrow_instance.global_position = muzzle.global_position
	arrow_instance.rotation = rotation

	await get_tree().create_timer(shoot_cooldown).timeout
	can_shoot = true
