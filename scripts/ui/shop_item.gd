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
	_update_max_state()

func _on_mouse_entered() -> void:
	item_hovered.emit(item_data.description if item_data else "")

func _on_mouse_exited() -> void:
	item_unhovered.emit()

func _on_card_pressed() -> void:
	if not player or not item_data:
		return
	if player.coincount >= item_data.price && Check_weapon_upgrade() && _can_apply_item():
		player.coincount -= item_data.price
		player.total_coins.text = str(player.coincount)
		apply_item_effect()
		item_data.price += 3
		item_purchased.emit()
		self.queue_free()
	else:
		card_button.modulate = Color(1.2, 0.3, 0.3, 1.0)
		await get_tree().create_timer(0.18).timeout
		card_button.modulate = Color(1, 1, 1, 1)

func _update_max_state() -> void:
	if not item_data or not player:
		return
	if _is_maxed_item():
		card_button.disabled = true
		card_button.modulate = Color(0.6, 0.6, 0.6, 1.0)
		if price_label:
			price_label.text = "MAX"
	else:
		card_button.disabled = false
		card_button.modulate = Color(1, 1, 1, 1)
		if price_label:
			price_label.text = str(item_data.price)

func _is_maxed_item() -> bool:
	if _is_speed_upgrade_item():
		return player.speed_multiplier >= player.max_speed_multiplier
	if _is_health_upgrade_item():
		return player.health_bonus >= player.max_health_bonus
	if _is_damage_upgrade_item("sword"):
		return player.sword_dmg_mult >= player.max_sword_dmg_mult
	if _is_damage_upgrade_item("bow"):
		return player.bow_dmg_mult >= player.max_bow_dmg_mult
	return false

func _can_apply_item() -> bool:
	return _can_apply_speed_upgrade() and _can_apply_health_upgrade() and _can_apply_damage_upgrade()

func _can_apply_speed_upgrade() -> bool:
	if not _is_speed_upgrade_item():
		return true
	if player.speed_multiplier >= player.max_speed_multiplier:
		return false
	return true

func _can_apply_health_upgrade() -> bool:
	if not _is_health_upgrade_item():
		return true
	if player.health_bonus >= player.max_health_bonus:
		return false
	return true

func _can_apply_damage_upgrade() -> bool:
	if _is_damage_upgrade_item("sword"):
		return player.sword_dmg_mult < player.max_sword_dmg_mult
	if _is_damage_upgrade_item("bow"):
		return player.bow_dmg_mult < player.max_bow_dmg_mult
	return true

func _is_speed_upgrade_item() -> bool:
	if not item_data:
		return false
	return item_data.speed_multiplier != 1.0 and not item_data.is_special and not item_data.is_upgrade and item_data.weapon_type == ""

func _is_health_upgrade_item() -> bool:
	if not item_data:
		return false
	return item_data.health_bonus > 0.0 and item_data.speed_multiplier == 1.0 and not item_data.is_special and not item_data.is_upgrade and item_data.weapon_type == ""

func _is_damage_upgrade_item(weapon_type: String) -> bool:
	if not item_data:
		return false
	return item_data.is_upgrade and item_data.weapon_type == weapon_type

func Check_weapon_upgrade():
	var is_upgrade_val = item_data.get("is_upgrade")
	if is_upgrade_val == false: return true
	var weapon_type_val = item_data.get("weapon_type")
	if player.active_weapon != weapon_type_val:
		return false
	else:
		return true

func apply_item_effect() -> void:
	if not item_data or not player:
		print("KLAIDA: Nėra duomenų arba žaidėjo!")
		return
	
	print("--- PRADEDAM PIRKIMĄ: ", item_data.item_name, " ---")
	
	if item_data.weapon_type != ""&& item_data.is_upgrade==false:
		print("Kodas nuėjo į: GINKLAI")
		player.add_weapon_to_inventory(item_data.weapon_type, item_data.item_name, item_data.icon)
		return

	if item_data.is_special:
		print("Kodas nuėjo į: SPECIALŪS (Bombos)")
		player.add_special_ammo(item_data.item_name, 5)
		return

	if item_data.is_upgrade && item_data.weapon_type == "sword":
		print("Kodas nuėjo į: UPGRADE (Žala)")
		player.upgrade_current_weapon(item_data.damage_multiplier,item_data.icon,item_data.weapon_type)
		return
	if item_data.is_upgrade && item_data.weapon_type == "bow":
		print("Kodas nuėjo į: UPGRADE (Žala)")
		player.upgrade_current_weapon(item_data.damage_multiplier,item_data.icon,item_data.weapon_type)
		return

	if _is_health_upgrade_item():
		print("Kodas nuėjo į: STATISTIKA (HP)")
		player.apply_health_upgrade(item_data.health_bonus)
		return

	# Jei kodas pasiekia šitą vietą, jis PRIVALO padidinti greitį
	print("Kodas nuėjo į: STATISTIKA")
	player.apply_speed_upgrade(item_data.speed_multiplier)
	print("Naujas greitis žaidėjo skripte: ", player.speed_multiplier)
