extends Entity

@onready var attack_area: Area2D = $AttackArea
@export var contact_damage: float = 10.0
@export var attack_cooldown_time: float = 1.0

var can_attack: bool = true
var player_ref: Node2D # Cached reference

func _ready():
	super._ready()
	# Cache the player once so we don't spam get_tree()
	player_ref = get_tree().get_first_node_in_group("player")
	# Clean up when dead
	died.connect(queue_free)

func _physics_process(_delta):
	if is_dead or not player_ref:
		velocity = Vector2.ZERO
		return
	
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
	await get_tree().create_timer(attack_cooldown_time).timeout
	can_attack = true
