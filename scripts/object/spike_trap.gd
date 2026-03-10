extends Node2D

@onready var sprite: AnimatedSprite2D = $spikes
@onready var area: Area2D = $Area2D

var damage := 10.0
var damage_interval := 0.5
var can_damage := true

func _ready():
	sprite.stop()
	sprite.frame = 0
	# Start with monitoring OFF so it doesn't hit people while retracted
	area.monitoring = false 
	run_cycle()

func run_cycle() -> void:
	while true:
		# 1. Wait while retracted (3 seconds)
		await get_tree().create_timer(3.0).timeout
		
		sprite.play()
		
		# 2. Wait until animation reaches frame 2 to enable damage
		while sprite.frame < 2:
			await sprite.frame_changed
		
		area.monitoring = true

		# 3. Wait for the animation to finish deploying (frame 4)
		var last_frame = sprite.sprite_frames.get_frame_count(sprite.animation) - 1
		while sprite.frame < last_frame:
			await sprite.frame_changed
			
		# 4. Hold at the last frame for 2 seconds (still dealing damage)
		await get_tree().create_timer(2.0).timeout
		
		# 5. Retract
		sprite.play_backwards()
		
		# 6. Wait until it retracts past the danger zone (frame 2) to disable damage
		while sprite.frame >= 2:
			await sprite.frame_changed
		
		area.monitoring = false
		
		await sprite.animation_finished

# This handles someone WALKING INTO the spikes while they are already up
func _on_Area2D_body_entered(body):
	_apply_spike_damage(body)

# This handles someone STANDING STILL while the spikes pop up underneath them
func _physics_process(_delta):
	if area.monitoring:
		for body in area.get_overlapping_bodies():
			_apply_spike_damage(body)

func _apply_spike_damage(body):
	if can_damage and body.has_method("take_damage"):
		body.take_damage(damage)
		_start_damage_cooldown()

func _start_damage_cooldown():
	can_damage = false
	await get_tree().create_timer(damage_interval).timeout
	can_damage = true
