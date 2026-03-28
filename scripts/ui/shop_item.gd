extends Control

@export var item_texture: TextureRect
@export var item_data: ItemData
var hovering: bool

signal item_hovered(description: String)
signal item_unhovered

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if item_data and item_data.icon:
		item_texture.texture = item_data.icon
		
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	hovering = true
	item_hovered.emit(item_data.description if item_data else "")

func _on_mouse_exited() -> void:
	hovering = false
	item_unhovered.emit()

func _input(event) -> void:
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed() and hovering:
			apply_item_effect()
			self.queue_free()

func apply_item_effect():
	if not item_data:
		return
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.damage_multiplier *= item_data.damage_multiplier
		player.speed_multiplier *= item_data.speed_multiplier
		player.defense += item_data.defense_bonus
