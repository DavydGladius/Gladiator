extends Control

@export var ShopItem: PackedScene
@export var available_items: Array[ItemData] = []
@onready var Upgrade_Container: HBoxContainer = $Panel/ShopInner/Upgrade_Container
@onready var Description: Label = $Panel/ShopInner/DescBox/Label
@onready var inventory_screen = $InventoryScreen

var current_item_indices: Array = []
var purchased_indices: Array = []
var _skip_next_shuffle: bool = false

func _ready() -> void:
	_shuffel_shop_no_save()
	Description.text = ""
	_apply_scale()
	get_viewport().size_changed.connect(_apply_scale)
	var wave_manager = get_tree().current_scene.find_child("WaveManager", true, false)
	if wave_manager:
		wave_manager.wave_started.connect(_on_wave_started)
	else:
		push_error("ShopScene: WaveManager nerastas!")
	if Global.load_save:
		_load_shop()
	else:
		_shuffel_shop_no_save()

func _apply_scale() -> void:
	var vp = get_viewport().get_visible_rect().size
	var s = clamp(min(vp.x / 1920.0, vp.y / 1080.0), 0.5, 1.0)
	var shop_w = int(620 * s)
	var shop_h = int(330 * s)
	var inv_w  = int(560 * s)
	var inv_h  = int(310 * s)
	var margin_left = int(40 * s)
	var margin_top  = int(130 * s)
	var shop_panel = get_node_or_null("Panel")
	if shop_panel:
		shop_panel.set_anchors_preset(0)
		shop_panel.offset_left  = margin_left
		shop_panel.offset_top   = margin_top
		shop_panel.offset_right  = margin_left + shop_w
		shop_panel.offset_bottom = margin_top  + shop_h
	var inv = get_node_or_null("InventoryScreen")
	if inv:
		var inv_left = margin_left + shop_w + int(16 * s)
		inv.set_anchors_preset(0)
		inv.offset_left  = inv_left
		inv.offset_top   = margin_top
		inv.offset_right  = inv_left + inv_w
		inv.offset_bottom = margin_top + inv_h

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			_shuffel_shop()
			if inventory_screen:
				inventory_screen.show_inventory()
		else:
			if inventory_screen:
				inventory_screen.hide_inventory()

func _on_wave_started(_wave_number: int) -> void:
	if _skip_next_shuffle:
		_skip_next_shuffle = false
		return
	_shuffel_shop()

func _shuffel_shop() -> void:
	current_item_indices.clear()
	purchased_indices.clear()
	current_item_indices = _pick_unique_indices(3)
	_save_shop()
	_build_shop()

func _shuffel_shop_no_save() -> void:
	current_item_indices.clear()
	purchased_indices.clear()
	current_item_indices = _pick_unique_indices(3)
	_build_shop()

func _pick_unique_indices(count: int) -> Array:
	var player = get_tree().get_first_node_in_group("player")
	var pool = []
	
	# Tikriname, ar išvis yra įkeltų daiktų inspektoriuje
	if available_items.size() == 0:
		print("!!! KLAIDA: available_items sąrašas yra TUŠČIAS inspektoriuje!")
		return []

	for i in range(available_items.size()):
		var item = available_items[i]
		
		# Tikriname ginklus
		if item.weapon_type != "":
			if player and player.has_method("has_weapon"):
				if player.has_weapon(item.item_name):
					print("--- Praleidžiam ginklą, kurį žaidėjas jau turi: ", item.item_name)
					continue
		
		pool.append(i)

	print("--- Galutinis Shop Pool Size: ", pool.size())
	
	pool.shuffle()
	var result = []
	for i in range(min(count, pool.size())):
		result.append(pool[i])
	return result

func _load_shop() -> void:
	var d = SaveManager.load_section("shop")
	if d.is_empty():
		_shuffel_shop_no_save()
		return
	var loaded_indices = d.get("item_indices", [])
	var loaded_purchased = d.get("purchased_indices", [])
	# Validacija
	if not loaded_indices is Array or loaded_indices.is_empty():
		_shuffel_shop_no_save()
		return
	for idx in loaded_indices:
		if not idx is float and not idx is int:
			_shuffel_shop_no_save()
			return
		if int(idx) >= available_items.size():
			_shuffel_shop_no_save()
			return
	current_item_indices = loaded_indices.map(func(x): return int(x))
	purchased_indices = loaded_purchased.map(func(x): return int(x))
	_build_shop()

# FIX: viešas metodas, kurį kviečia pause_menu ir death_screen po load
func load_shop_from_save() -> void:
	_skip_next_shuffle = true  # Neleidžiame wave_started perrašyti ką tik įkeltų duomenų
	_load_shop()

func _save_shop() -> void:
	SaveManager.save_section("shop", {
		"item_indices": current_item_indices,
		"purchased_indices": purchased_indices
	})

func _build_shop() -> void:
	# Išvalom senas korteles
	for child in Upgrade_Container.get_children():
		child.queue_free()
		
	for i in range(current_item_indices.size()):
		# Jei daiktas šiame wave jau nupirktas, jo nekuriam
		if i in purchased_indices:
			continue
			
		var idx = current_item_indices[i]
		if idx >= available_items.size(): continue
		
		var shop_item = ShopItem.instantiate()
		shop_item.item_data = available_items[idx]
		shop_item.set_meta("slot_index", i) # Išsisaugom slot'ą pirkimui
		Upgrade_Container.add_child(shop_item)
		
		shop_item.item_hovered.connect(_on_item_hovered)
		shop_item.item_unhovered.connect(_on_item_unhovered)
		shop_item.item_purchased.connect(_on_item_purchased.bind(shop_item))

func _on_item_hovered(description: String) -> void:
	Description.text = description

func _on_item_unhovered() -> void:
	Description.text = ""

func _on_item_purchased(shop_item: Control) -> void:
	var slot = shop_item.get_meta("slot_index", -1)
	if slot != -1 and slot not in purchased_indices:
		purchased_indices.append(slot)
		_save_shop()
	if inventory_screen:
		inventory_screen.refresh_inventory()
