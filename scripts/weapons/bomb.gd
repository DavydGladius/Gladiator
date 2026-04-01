extends RigidBody2D

@export var damage := 50.0
@export var explosion_lifetime := 2.0 # Padidink, kad partiklai spėtų išnykti

@onready var a_o_e = $boom
@onready var sprite = $Sprite2D
@onready var timer = $Timer
@onready var particles = $ExplosionParticles
@onready var sound = $AudioStreamPlayer2D

var has_exploded = false

func _ready():
	show() 
	if sprite:
		sprite.show()
		sprite.z_index = 100
		sprite.scale = Vector2(0.5, 0.5)
	
	# Fizika: bomba "čiuožia", bet nekrenta žemyn
	gravity_scale = 0
	linear_damp = 5.0 
	
	# Laikmatis iki sprogimo
	timer.one_shot = true
	timer.start(2.0)
	if not timer.timeout.is_connected(explode):
		timer.timeout.connect(explode)

func _process(_delta):
	# Pulsavimas prieš sprogstant
	if not has_exploded:
		if timer.time_left < 0.9:
			var s = 0.5 + sin(Time.get_ticks_msec() * 0.05) * 0.1
			sprite.scale = Vector2(s, s)
			sprite.modulate = Color(2, 1, 1) # Raudonuoja
		else:
			sprite.scale = Vector2(0.5, 0.5)
			sprite.modulate = Color(1, 1, 1)

func explode():
	if has_exploded: return
	has_exploded = true
	
	print("--- SPROGIMAS ---")
	
	# 1. ŽALOS LOGIKA
	if a_o_e:
		var targets = a_o_e.get_overlapping_bodies() + a_o_e.get_overlapping_areas()
		for target in targets:
			# Filtruojam šiukšles (grindis, pačią bombą)
			if target == self or target.get_parent() == self: continue
			if target is TileMapLayer: continue
			
			if target.has_method("take_damage"):
				target.take_damage(damage)
				print("Žala padaryta: ", target.name)

	# 2. VIZUALAI (PARTIKLAI)
	if sprite:
		sprite.hide() # Bomba dingsta, bet objektas dar lieka dėl partiklų
	
	freeze = true # Bomba sustoja vietoje
	
	if sound:
		sound.play()
	
	if particles:
		particles.emitting = true # PALEIDŽIAM DALELĖS
		# Jei nori, kad dalelės liktų vietoje, net jei bomba judėtų:
		# particles.set_as_top_level(true) 

	# 3. LAUKIMAS IR IŠTRYNIMAS
	# Laukiame pakankamai ilgai, kad partiklai spėtų baigti savo ciklą
	await get_tree().create_timer(explosion_lifetime).timeout
	queue_free()
