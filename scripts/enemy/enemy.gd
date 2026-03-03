extends Entity

@onready var attack_area: Area2D = $AttackArea
@export var contact_damage: float = 10.0
@export var attack_cooldown_time: float = 1.0

var can_attack: bool = true
var player_ref: Node2D

func _ready():
	super._ready()
	player_ref = get_tree().get_first_node_in_group("player")
	# Entity handled the animation, so we just delete the node now
	died.connect(queue_free)

func _physics_process(_delta):
	if is_dead or not player_ref or player_ref.is_dead:
		velocity = Vector2.ZERO
		return

	var dist = global_position.distance_to(player_ref.global_position)
	
	# If the enemy is right next to the player, stop moving to prevent "vibrating"
	if dist < 15: 
		velocity = Vector2.ZERO
		update_animations(Vector2.ZERO)
	else:
		var direction = global_position.direction_to(player_ref.global_position)
		handle_movement(direction)
	
	if can_attack:
		check_for_attacks()

func check_for_attacks():
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			perform_attack(body)
			break

func perform_attack(target):
	can_attack = false
	target.take_damage(contact_damage)
	
	# Safety check to prevent the 'null' tree error
	if is_inside_tree():
		await get_tree().create_timer(attack_cooldown_time).timeout
		can_attack = true
