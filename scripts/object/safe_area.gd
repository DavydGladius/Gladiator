extends Area2D

@onready var wave_manager = get_parent().get_node("WaveManager")

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Žaidėjas saugus!")
		if wave_manager:
			wave_manager.stop_wave()
			wave_manager.clear_enemies()
		# Tiesiog parodome CanvasLayer – shop_scene pati animuosis per _notification
		$CanvasLayer.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		print("Žaidėjas paliko saugią zoną!")
		# Slide-out animacija, tada slepiame ir startuojame bangą
		var shop_node = $CanvasLayer.get_node_or_null("ShopScene")
		if shop_node and shop_node.has_method("animate_out_then_hide"):
			shop_node.animate_out_then_hide(func():
				$CanvasLayer.visible = false
				if wave_manager:
					if wave_manager.in_grace_period:
						wave_manager.resume_grace_period()
					else:
						wave_manager.restart_current_wave()
			)
		else:
			$CanvasLayer.visible = false
			if wave_manager:
				if wave_manager.in_grace_period:
					wave_manager.resume_grace_period()
				else:
					wave_manager.restart_current_wave()
