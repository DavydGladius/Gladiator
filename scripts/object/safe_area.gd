extends Area2D

# Naudojame @onready, kad rastume WaveManager per tėvą (World)
@onready var wave_manager = get_parent().get_node("WaveManager")

func _ready():
	# Sujungiame signalus, kad jie veiktų automatiškai
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Žaidėjas saugus!")
		$CanvasLayer.visible = true
		if wave_manager:
			wave_manager.stop_wave()
			wave_manager.clear_enemies() # Čia ištrinami priešai
		body.modulate.a = 0.5

func _on_body_exited(body):
	if body.is_in_group("player"):
		print("Žaidėjas paliko saugią zoną!")
		$CanvasLayer.visible = false
		if wave_manager:
			wave_manager.restart_current_wave() # Čia banga prasideda iš naujo
		body.modulate.a = 1.0
