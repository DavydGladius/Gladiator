extends Node2D

@onready var player_sprite: AnimatedSprite2D = $"../AnimatedSprite2D"
@onready var attack_area: Area2D = $AttackArea

@export var damage: float = 25.0
@export var base_x: float = 6.0   
@export var base_y: float = 7.0      
@export var idle_offset: float = 1.5 
@export var angle_right: float = -25.0 
@export var angle_left: float = 25.0   

var is_attacking: bool = false

func _process(_delta: float) -> void:
	if not is_attacking:
		handle_visuals()
	
	if Input.is_action_just_pressed("attack") and not is_attacking:
		perform_attack()

func handle_visuals():
	if player_sprite.flip_h:
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
	
	if player_sprite.animation == "walk":
		current_base_y = base_y
		speed = 0.012
		strength = 0.4
	else:
		current_base_y = base_y + idle_offset
		
	position.y = current_base_y + sin(Time.get_ticks_msec() * speed) * strength

func perform_attack():
	is_attacking = true
	
	scale.x = 1
	
	var attack_direction = get_global_mouse_position()
	look_at(attack_direction)
	
	var targets = attack_area.get_overlapping_bodies()
	for target in targets:
		if target.has_method("take_damage") and target != get_parent():
			target.take_damage(damage)
	
	# ANIMACIJA
	var start_rot = rotation_degrees
	var tween = create_tween()
	
	tween.set_trans(Tween.TRANS_QUART)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "rotation_degrees", start_rot + 110, 0.1)
	tween.tween_property(self, "rotation_degrees", start_rot, 0.1)
	await tween.finished
	
	is_attacking = false
