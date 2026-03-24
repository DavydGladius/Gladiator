extends TileMapLayer

@onready var deco = $"../Decorations"


func _tile_data_runtime_update(_coords: Vector2i, tile_data: TileData) -> void:
	tile_data.set_navigation_polygon(0, null)


func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	var global_pos = to_global(map_to_local(coords))
	var deco_coords = deco.local_to_map(deco.to_local(global_pos))
	return deco_coords in deco.get_used_cells_by_id(0)
