extends Control

func _ready():
	visible = false;

func Continue():
	get_tree().paused = false;
	visible = false;

func Pause():
	get_tree().paused = true;
	visible = true;


func testEsc():
	if Input.is_action_just_pressed("Escape") and !get_tree().paused:
		Pause()
	elif Input.is_action_just_pressed("Escape") and get_tree().paused:
		Continue()

func _on_continue_pressed() -> void:
	Continue()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()

func _process(delta):
	testEsc()
