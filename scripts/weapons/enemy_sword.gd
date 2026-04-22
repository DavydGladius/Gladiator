extends Node2D

@onready var enemy_sprite: AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var attack_area: Area2D = $AttackArea
@onready var swing_sound: AudioStreamPlayer2D = $SwingSound

@export var damage: float = 25.0
@export var base_x: float = 6.0
@export var base_y: float = 7.0
@export var idle_offset: float = 1.5
@export var angle_right: float = -25.0
@export var angle_left: float = 25.0

var is_attacking: bool = false

func _process(_delta: float) -> void:
	if not is_visible_in_tree(): return
	if not is_attacking:
		handle_visuals()

func handle_visuals():
	if enemy_sprite.flip_h:
		position.x = -base_x
		scale.x = -1
		rotation_degrees = angle_left
	else:
		position.x = base_x
		scale.x = 1
		rotation_degrees = angle_right

	var current_base_y = base_y
	var speed = 0.004
	var strength = 0.2

	if enemy_sprite.animation == "walk":
		current_base_y = base_y
		speed = 0.012
		strength = 0.4
	else:
		current_base_y = base_y + idle_offset

	position.y = current_base_y + sin(Time.get_ticks_msec() * speed) * strength

func swing(target_position: Vector2) -> void:
	print("swing called!")
	if is_attacking: return
	print("swing started!")
	is_attacking = true
	if swing_sound:
		swing_sound.pitch_scale = randf_range(0.9, 1.1)
		swing_sound.play()

	look_at(target_position)
	var start_rot = rotation_degrees
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_QUART)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", start_rot + 110, 0.1)
	tween.tween_property(self, "rotation_degrees", start_rot, 0.1)
	await tween.finished
	is_attacking = false

func get_overlapping_bodies() -> Array:
	return attack_area.get_overlapping_bodies()
