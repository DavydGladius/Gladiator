extends Control

@export var ShopItem: PackedScene
@export var available_items: Array[ItemData] = []
@onready var Upgrade_Container: HBoxContainer = $Panel/ShopInner/Upgrade_Container
@onready var Description: Label = $Panel/ShopInner/DescBox/Label
@onready var inventory_screen = $InventoryScreen

var player
var current_item_indices: Array = []
var purchased_indices: Array = []
var _skip_next_shuffle: bool = false

var _tween: Tween = null
const DUR       := 0.52
const SLIDE_AMT := 80.0   # pikseliai slinkimui

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
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

func _animate_in() -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	# _apply_scale jau iškviesta prieš tai, offset'ai teisingi
	var shop_panel = get_node_or_null("Panel")
	var inv = get_node_or_null("InventoryScreen")
	# Tikslinės offset reikšmės (nustatytos _apply_scale)
	var sp_left  = shop_panel.offset_left  if shop_panel else 0.0
	var sp_right = shop_panel.offset_right if shop_panel else 0.0
	var inv_left  = inv.offset_left  if inv else 0.0
	var inv_right = inv.offset_right if inv else 0.0
	# Pradinė pozicija: shop slenka iš kairės, inv iš dešinės
	if shop_panel:
		shop_panel.offset_left  = sp_left  - SLIDE_AMT
		shop_panel.offset_right = sp_right - SLIDE_AMT
		shop_panel.modulate.a = 0.0
	if inv:
		inv.offset_left  = inv_left  + SLIDE_AMT
		inv.offset_right = inv_right + SLIDE_AMT
		inv.modulate.a = 0.0
	_tween = create_tween().set_parallel(true)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.set_trans(Tween.TRANS_BACK)
	if shop_panel:
		_tween.tween_property(shop_panel, "offset_left",  sp_left,  DUR)
		_tween.tween_property(shop_panel, "offset_right", sp_right, DUR)
		_tween.tween_property(shop_panel, "modulate:a", 1.0, DUR * 0.7)
	if inv:
		_tween.tween_property(inv, "offset_left",  inv_left,  DUR).set_delay(0.04)
		_tween.tween_property(inv, "offset_right", inv_right, DUR).set_delay(0.04)
		_tween.tween_property(inv, "modulate:a", 1.0, DUR * 0.7).set_delay(0.04)

func animate_out_then_hide(on_done: Callable) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	var shop_panel = get_node_or_null("Panel")
	var inv = get_node_or_null("InventoryScreen")
	# Dabartinės (teisingos) offset reikšmės
	var sp_left  = shop_panel.offset_left  if shop_panel else 0.0
	var sp_right = shop_panel.offset_right if shop_panel else 0.0
	var inv_left  = inv.offset_left  if inv else 0.0
	var inv_right = inv.offset_right if inv else 0.0
	_tween = create_tween().set_parallel(true)
	_tween.set_ease(Tween.EASE_IN)
	_tween.set_trans(Tween.TRANS_QUAD)
	# Išeina: shopas į kairę, inv į dešinę
	if shop_panel:
		_tween.tween_property(shop_panel, "offset_left",  sp_left  - SLIDE_AMT, DUR * 0.75)
		_tween.tween_property(shop_panel, "offset_right", sp_right - SLIDE_AMT, DUR * 0.75)
		_tween.tween_property(shop_panel, "modulate:a", 0.0, DUR * 0.55)
	if inv:
		_tween.tween_property(inv, "offset_left",  inv_left  + SLIDE_AMT, DUR * 0.75).set_delay(0.03)
		_tween.tween_property(inv, "offset_right", inv_right + SLIDE_AMT, DUR * 0.75).set_delay(0.03)
		_tween.tween_property(inv, "modulate:a", 0.0, DUR * 0.55).set_delay(0.03)
	_tween.set_parallel(false)
	_tween.tween_callback(func():
		# Atstatome teisingas pozicijas prieš slėpiant
		if shop_panel:
			shop_panel.offset_left  = sp_left
			shop_panel.offset_right = sp_right
			shop_panel.modulate.a = 1.0
		if inv:
			inv.offset_left  = inv_left
			inv.offset_right = inv_right
			inv.modulate.a = 1.0
		on_done.call()
	)

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if visible:
			_shuffel_shop()
			if inventory_screen:
				inventory_screen.show_inventory()
			_animate_in()
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
	var player_node = get_tree().get_first_node_in_group("player")
	var pool = []
	if available_items.size() == 0:
		print("!!! KLAIDA: available_items sąrašas yra TUŠČIAS inspektoriuje!")
		return []
	for i in range(available_items.size()):
		var item = available_items[i]
		if item.weapon_type != "" and not item.is_upgrade:
			if player_node and player_node.has_method("has_weapon"):
				if player_node.has_weapon(item.item_name):
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

func load_shop_from_save() -> void:
	_skip_next_shuffle = true
	_load_shop()

func _save_shop() -> void:
	SaveManager.save_section("shop", {
		"item_indices": current_item_indices,
		"purchased_indices": purchased_indices
	})

func _build_shop() -> void:
	for child in Upgrade_Container.get_children():
		child.queue_free()
	for i in range(current_item_indices.size()):
		if i in purchased_indices:
			continue
		var idx = current_item_indices[i]
		if idx >= available_items.size(): continue
		var shop_item = ShopItem.instantiate()
		shop_item.item_data = available_items[idx]
		shop_item.set_meta("slot_index", i)
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
	if player.sword_dmg_mult >= player.max_sword_dmg_mult:
		var new_tier = load("res://scripts/resources/Sword_Damage_Tier_II.tres")
		available_items[1] = new_tier
	if slot != -1 and slot not in purchased_indices:
		purchased_indices.append(slot)
		_save_shop()
	if inventory_screen:
		inventory_screen.refresh_inventory()
