class_name ItemData extends Resource

@export var item_name: String = ""
@export var icon: Texture2D
@export var description: String = ""
@export var price: int = 0

# Stat bonuses (upgrade items)
@export var damage_multiplier: float = 1.0
@export var speed_multiplier: float = 1.0
@export var health_bonus: float = 0.0

# Weapon type: "bow", "sword"
@export var weapon_type: String = ""
