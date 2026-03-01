extends Entity

@onready var attack_area: Area2D = $AttackArea
@export var contact_damage: float = 10.0
@export var attack_cooldown_time: float = 1.0

var can_attack: bool = true

func _physics_process(_delta):
	if is_dead:
		velocity = Vector2.ZERO
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var direction = global_position.direction_to(player.global_position)
		handle_movement(direction)
		
		if can_attack:
			var targets = attack_area.get_overlapping_bodies()
			for target in targets:
				if target.is_in_group("player"):
					perform_attack(target)
					break

func perform_attack(target):
	can_attack = false
	
	target.take_damage(contact_damage)
	
	# ATEICIAI
	# galima paleisti priešo puolimo animaciją, jei tokią turi
	# animations.play("attack") 

	await get_tree().create_timer(attack_cooldown_time).timeout
	can_attack = true
