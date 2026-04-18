extends Entity

var coincount: int = 0
@onready var footstep_audio = $FootstepPlayer
@onready var total_coins = $CanvasLayer/TextureRect/Label

@onready var spawnpos = $".".global_position

@onready var sword = $BasicSword
@onready var bow = $BasicBow

@export var bomb_scene: PackedScene
@export var throw_force: float = 600.0

# Inventoriaus sistema
var inventory: Array = []
var active_weapon: String = "sword"

signal inventory_changed

var damage_multiplier: float = 1.0
var speed_multiplier: float = 1.0
var health_bonus: float = 0.0

@export var sword_item: Resource  # BasicSwordItem.tres

func _ready():
	super._ready()
	add_to_group("player")
	died.connect(_on_player_died)
	
	if footstep_audio is AudioStreamPlayer2D:
		footstep_audio.max_distance = 2000
	
	var sword_icon = null
	var sword_res = load("res://scripts/resources/BasicSwordItem.tres")
	if sword_res:
		sword_icon = sword_res.icon
	inventory.append({"weapon_type": "sword", "name": "Basic Sword", "icon": sword_icon, "quantity": 1})
	switch_weapon("sword")

func _physics_process(_delta):
	if is_dead: return 
	var direction = Input.get_vector("left", "right", "up", "down")
	handle_movement(direction)
	
	if Input.is_action_just_pressed("bomb"):
		throw_bomb()

func switch_weapon(weapon_type: String):
	if weapon_type == "sword":
		sword.show()
		sword.process_mode = PROCESS_MODE_INHERIT
		bow.hide()
		bow.process_mode = PROCESS_MODE_DISABLED
	elif weapon_type == "bow":
		bow.show()
		bow.process_mode = PROCESS_MODE_INHERIT
		sword.hide()
		sword.process_mode = PROCESS_MODE_DISABLED
		
func heal_full():
	current_health = max_health + health_bonus
	if health_bar:
		health_bar.max_value = current_health
		health_bar.value = current_health

func throw_bomb():
	if not bomb_scene:
		print("KLAIDA: Nepamiršk įtempti Bomb.tscn į inspektorių!")
		return

	var b = bomb_scene.instantiate()
	get_tree().current_scene.add_child(b)
	b.global_position = global_position
	
	var rb: RigidBody2D = null
	if b is RigidBody2D:
		rb = b
	else:
		rb = b.get_node_or_null("Explosive")
	
	if rb:
		if rb != b:
			rb.global_position = global_position
		var dir = (get_global_mouse_position() - global_position).normalized()
		rb.linear_velocity = Vector2.ZERO
		rb.apply_central_impulse(dir * throw_force)
	else:
		print("KLAIDA: Bombos scenoje nerastas RigidBody2D!")

func add_weapon_to_inventory(weapon_type: String, weapon_name: String, icon) -> void:
	for item in inventory:
		if item["weapon_type"] == weapon_type:
			item["quantity"] = item.get("quantity", 1) + 1
			emit_signal("inventory_changed")
			return
	
	inventory.append({
		"weapon_type": weapon_type,
		"name": weapon_name,
		"icon": icon,
		"quantity": 1
	})
	emit_signal("inventory_changed")
	switch_weapon(weapon_type)
	active_weapon = weapon_type

func get_inventory() -> Array:
	return inventory

func _on_player_died():
	coincount = round(float(coincount * 0.9))
	if total_coins: total_coins.text = str(coincount)
	
	var wave_manager = get_tree().current_scene.find_child("WaveManager", true, false)
	if wave_manager:
		wave_manager.current_wavelvl = max(1, wave_manager.current_wavelvl - 1)
		wave_manager.stop_wave()
		wave_manager.clear_enemies()
	
	var death_screen = get_tree().current_scene.find_child("DeathScreen", true, false)
	if death_screen:
		death_screen.show_menu()

func _on_collect_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("coin"):
		coincount += area.collect()
		total_coins.text = str(coincount)

func _icon_for_weapon(wtype: String):
	match wtype:
		"sword":
			var res = load("res://scripts/resources/BasicSwordItem.tres")
			return res.icon if res else null
		"bow":
			var res = load("res://scripts/resources/BasicBowItem.tres")
			return res.icon if res else null
	return null

func save_player_data() -> void:
	var inventory_data: Array = []
	for item in inventory:
		inventory_data.append({
			"weapon_type": item["weapon_type"],
			"name": item["name"],
			"quantity": item.get("quantity", 1)
		})
	SaveManager.save_section("player", {
		"damage_multiplier": damage_multiplier,
		"speed_multiplier": speed_multiplier,
		"health_bonus": health_bonus,
		"current_health": current_health,
		"coincount": coincount,
		"inventory": inventory_data,
		"active_weapon": active_weapon
	})

func load_player_data() -> void:
	var d = SaveManager.load_section("player")
	if d.is_empty():
		return
	damage_multiplier = float(d.get("damage_multiplier", 1.0))
	speed_multiplier  = float(d.get("speed_multiplier",  1.0))
	health_bonus      = float(d.get("health_bonus",      0.0))
	current_health    = float(d.get("current_health",    max_health))
	coincount         = int(d.get("coincount", 0))
	total_coins.text  = str(coincount)
	global_position   = spawnpos

	inventory.clear()
	for item_data in d.get("inventory", []):
		var wtype = item_data.get("weapon_type", "")
		inventory.append({
			"weapon_type": wtype,
			"name":        item_data.get("name", ""),
			"icon":        _icon_for_weapon(wtype),
			"quantity":    int(item_data.get("quantity", 1))
		})
	active_weapon = d.get("active_weapon", "sword")
	switch_weapon(active_weapon)
	emit_signal("inventory_changed")
