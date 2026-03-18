extends Node2D

@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("expanded")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite.play("closed")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		sprite.play("expanded")
