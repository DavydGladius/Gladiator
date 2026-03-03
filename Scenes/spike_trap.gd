extends Node2D

@onready var sprite: AnimatedSprite2D = $spikes
@onready var area: Area2D = $Area2D

var damage := 10
var damage_interval := 0.5
var can_damage := true


func _ready():
	print("Spike script loaded")
	sprite.stop()
	sprite.frame = 0
	
	area.monitoring = false
	
	run_cycle()


func run_cycle() -> void:
	while true:
		await get_tree().create_timer(3.0).timeout
		
		sprite.play()
		
		var last_frame = sprite.sprite_frames.get_frame_count(sprite.animation) - 1
		while sprite.frame != last_frame:
			await sprite.frame_changed
		# Decided to freeze it on last frame for 2 seconds,
		# cuz otherwise it would instantly loop back and that looks super fkin disgusting
		await get_tree().create_timer(2.0).timeout
		
		sprite.play_backwards()
		await sprite.animation_finished
		
		await get_tree().create_timer(3.0).timeout


# KYS KYS KYS it doesnt work. HELPPPP
func deal_damage():
	if not can_damage:
		return
		
	can_damage = false
	
	for body in area.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.take_damage(damage)
			break

	await get_tree().create_timer(damage_interval).timeout
	can_damage = true

func _on_Area2D_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(damage)
