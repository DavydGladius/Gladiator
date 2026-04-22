extends "res://scripts/enemy/enemy.gd"

@onready var sword: Node2D = $BasicSword

func perform_attack(target):
	print("perform_attack called!")
	can_attack = false
	await sword.swing(target.global_position)
	
	for body in sword.get_overlapping_bodies():
		if body.is_in_group("player"):
			print("Sword hit player!")
			body.take_damage(sword.damage)
	
	await get_tree().create_timer(attack_cooldown_time).timeout
	can_attack = true
