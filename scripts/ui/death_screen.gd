extends Control

func _ready():
	visible = false

func show_menu():
	show()
	get_tree().paused = true

func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	hide()
	print("MYGTUKAS PASPAUSTAS!")
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_dead = false
		player.set_physics_process(true)
		player.health = player.max_health
	
	print("Grįžtam į kovą!")

func _on_end_button_pressed() -> void:
	get_tree().quit()
