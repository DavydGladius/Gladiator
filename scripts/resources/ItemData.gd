class_name ItemData extends Resource

@export var item_name: String = ""
@export var icon: Texture2D
@export var description: String = ""
@export var price: int = 0
@export var amount: int = 0

# LOGIKA: Šie kintamieji valdo shop_item.gd "if" sąlygas
@export var is_special: bool = false   # Varnelė bomboms
@export var is_upgrade: bool = false   # Varnelė galios didinimui
@export var weapon_type: String = ""   # "bow" arba "sword"

# STATISTIKA
@export var damage_multiplier: float = 1.0
@export var speed_multiplier: float = 1.0
@export var health_bonus: float = 0.0
