extends Control

@onready var items_container = $Panel/VBoxContainer/ItemContainer

var player

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if player:
		player.inventory_changed.connect(refresh_inventory)
	visible = false
	var panel = get_node_or_null("Panel")
	if panel:
		panel.set_anchors_preset(15)
		panel.offset_left = 0
		panel.offset_top = 0
		panel.offset_right = 0
		panel.offset_bottom = 0
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
		lbl.text = "— tuščia —"
		lbl.add_theme_color_override("font_color", Color(0.55, 0.5, 0.45, 1.0))
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		items_container.add_child(lbl)
		return

	for item in inv:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)

	# 1. Tarpas kairėje
		var spacer_left = Control.new()
		spacer_left.custom_minimum_size = Vector2(12, 0)
		row.add_child(spacer_left)

	# 2. Ikona
		var tex = TextureRect.new()
		tex.custom_minimum_size = Vector2(22, 22)
		tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if item.get("icon"):
			tex.texture = item["icon"]
		row.add_child(tex)

	# 3. Pavadinimas ir kiekis
		var name_lbl = Label.new()
		var qty = item.get("quantity", 1)
		var iname = item.get("name", "")
		name_lbl.text = iname + (" x" + str(qty) if qty > 1 else "")
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		name_lbl.add_theme_color_override("font_color", Color(0.92, 0.88, 0.78, 1.0))
		name_lbl.add_theme_font_size_override("font_size", 14)
		row.add_child(name_lbl)

		var wtype = item.get("weapon_type", "")
	
		var is_real_weapon = (wtype == "sword" or wtype == "bow")

		if is_real_weapon:
			var btn = Button.new()
			btn.custom_minimum_size = Vector2(52, 0)
		
			if player.active_weapon == wtype:
				btn.text = "✔ Active"
				btn.disabled = true
				btn.add_theme_color_override("font_color", Color(0.4, 0.9, 0.45, 1.0))
			else:
				btn.text = "Equip"
				btn.add_theme_color_override("font_color", Color(1.0, 0.87, 0.2, 1.0))
				btn.pressed.connect(func():
					player.switch_weapon(wtype)
					player.active_weapon = wtype
					refresh_inventory()
				)
			btn.add_theme_font_size_override("font_size", 13)
			row.add_child(btn)
		else:
			var placeholder = Control.new()
			placeholder.custom_minimum_size = Vector2(52, 0)
			row.add_child(placeholder)

	# 5. Tarpas dešinėje
		var spacer_right = Control.new()
		spacer_right.custom_minimum_size = Vector2(8, 0)
		row.add_child(spacer_right)

		items_container.add_child(row)
