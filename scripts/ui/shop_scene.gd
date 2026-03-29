extends Control

@export var ShopItem:PackedScene
@export var available_items: Array[ItemData] = []
@onready var Upgrade_Container: HBoxContainer = $Upgrade_Container
@onready var Description: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Description.text = ""
	var wave_manager = $"../../../WaveManager"
	if wave_manager:
		wave_manager.wave_started.connect(_on_wave_started)

func _on_wave_started(wave_number: int) -> void:
	_shuffel_shop()

func _shuffel_shop():
	#Istrina senus
	for child in Upgrade_Container.get_children():
		child.queue_free()

	for i in range(3):
		var shop_item = ShopItem.instantiate()
		shop_item.item_data = available_items.pick_random()
		Upgrade_Container.add_child(shop_item)
		shop_item.item_hovered.connect(_on_item_hovered)
		shop_item.item_unhovered.connect(_on_item_unhovered)

func _on_item_hovered(description: String) -> void:
	Description.text = description

func _on_item_unhovered() -> void:
	Description.text = ""
