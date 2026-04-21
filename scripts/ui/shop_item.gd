extends Control

@export var item_texture: TextureRect
var item_data: ItemData:
	set(value):
		item_data = value
		if is_node_ready():
			_setup()

@onready var price_label = $Card/VBox/PriceBadge/PriceRow/Price
@onready var card_button: Button = $Card

signal item_hovered(description: String)
signal item_unhovered
signal item_purchased
var player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	_setup()
	card_button.pressed.connect(_on_card_pressed)
	card_button.mouse_entered.connect(_on_mouse_entered)
	card_button.mouse_exited.connect(_on_mouse_exited)

func _setup() -> void:
	if item_data and item_texture and item_data.icon:
		item_texture.texture = item_data.icon
	if item_data and price_label:
		price_label.text = str(item_data.price)

func _on_mouse_entered() -> void:
	item_hovered.emit(item_data.description if item_data else "")

func _on_mouse_exited() -> void:
	item_unhovered.emit()

func _on_card_pressed() -> void:
	if not player or not item_data:
		return
	if player.coincount >= item_data.price:
		player.coincount -= item_data.price
		player.total_coins.text = str(player.coincount)
		apply_item_effect()
		item_purchased.emit()
		self.queue_free()
	else:
		card_button.modulate = Color(1.2, 0.3, 0.3, 1.0)
		await get_tree().create_timer(0.18).timeout
		card_button.modulate = Color(1, 1, 1, 1)

func apply_item_effect() -> void:
	if not item_data or not player:
		return
	if item_data.weapon_type != "":
		player.add_weapon_to_inventory(item_data.weapon_type, item_data.item_name, item_data.icon)
	else:
		player.damage_multiplier *= item_data.damage_multiplier
		player.speed_multiplier *= item_data.speed_multiplier
		player.max_health += item_data.health_bonus
		player.current_health += item_data.health_bonus
