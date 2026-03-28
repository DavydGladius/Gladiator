extends Control

@export var ShopItem:PackedScene
@export var available_items: Array[ItemData] = []
@export var Item_Container: HBoxContainer
@onready var Description: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Description.text = ""
	for i in range(5):
		var shop_item = ShopItem.instantiate()
		
		Item_Container.add_child(shop_item)
		shop_item.item_hovered.connect(_on_item_hovered)
		shop_item.item_unhovered.connect(_on_item_unhovered)

func _on_item_hovered(description: String) -> void:
	Description.text = description

func _on_item_unhovered() -> void:
	Description.text = ""
