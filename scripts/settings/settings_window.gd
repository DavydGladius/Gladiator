extends Panel

signal closed 

func _on_back_pressed() -> void:
	AudioManager.play_click()
	
	self.hide()
	
	closed.emit()
