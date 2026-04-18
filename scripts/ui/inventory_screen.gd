extends Control

@onready var items_container = $Panel/VBoxContainer/ItemContainer

var player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.inventory_changed.connect(refresh_inventory)
	visible = false
	refresh_inventory()

func show_inventory() -> void:
	refresh_inventory()
	visible = true

func hide_inventory() -> void:
	visible = false

func refresh_inventory() -> void:
	if not items_container:
		return
	for child in items_container.get_children():
		child.queue_free()

	if not player:
		return

	var inv = player.get_inventory()
	if inv.is_empty():
		var lbl = Label.new()
		lbl.text = "Inventorius tuscias"
		items_container.add_child(lbl)
		return

	for item in inv:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		# Ikona
		var tex = TextureRect.new()
		tex.custom_minimum_size = Vector2(32, 32)
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if item["icon"]:
			tex.texture = item["icon"]
		row.add_child(tex)

		# Pavadinimas
		var name_lbl = Label.new()
		var qty = item.get("quantity", 1)
		name_lbl.text = item["name"] + (" x" + str(qty) if qty > 1 else "")
		name_lbl.custom_minimum_size = Vector2(100, 0)
		name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		row.add_child(name_lbl)

		# Mygtukas
		var btn = Button.new()
		var wtype = item["weapon_type"]
		if player.active_weapon == wtype:
			btn.text = "Active"
			btn.disabled = true
		else:
			btn.text = "Use"
			btn.pressed.connect(func():
				player.switch_weapon(wtype)
				player.active_weapon = wtype
				refresh_inventory()
			)
		row.add_child(btn)

		items_container.add_child(row)
