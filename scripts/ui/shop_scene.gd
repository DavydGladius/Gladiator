extends Control

@export var ShopItem: PackedScene
@export var available_items: Array[ItemData] = []
@onready var Upgrade_Container: HBoxContainer = $Upgrade_Container
@onready var Description: Label = $Label
@onready var inventory_screen = $InventoryScreen

var current_item_indices: Array = []
var purchased_indices: Array = []
var _skip_next_shuffle: bool = false

func _ready() -> void:
	Description.text = ""
	var wave_manager = get_tree().current_scene.find_child("WaveManager", true, false)
	if wave_manager:
		wave_manager.wave_started.connect(_on_wave_started)
	else:
		push_error("ShopScene: WaveManager nerastas!")
	if Global.load_save:
		_load_shop()
	else:
		_shuffel_shop_no_save()

func _notification(what: int) -> void:
	if what == NOTIFICATION_VISIBILITY_CHANGED:
		if inventory_screen:
			if visible:
				inventory_screen.show_inventory()
			else:
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

# FIX: visada parenkame skirtingus itemus (jei yra pakankamai)
func _pick_unique_indices(count: int) -> Array:
	var pool = range(available_items.size())
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
	for child in Upgrade_Container.get_children():
		child.queue_free()
	for i in range(current_item_indices.size()):
		if i in purchased_indices:
			continue
		var idx = current_item_indices[i]
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
	if slot != -1 and slot not in purchased_indices:
		purchased_indices.append(slot)
		_save_shop()
	if inventory_screen:
		inventory_screen.refresh_inventory()
