extends Node

const SAVE_PATH = "user://savefile.json"

# Nuskaito visą JSON failą ir grąžina Dictionary, arba {} jei nėra/klaida
func load_all() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return {}
	var text = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed is Dictionary:
		return parsed
	return {}

# Išsaugo visą Dictionary į JSON failą
func save_all(data: Dictionary) -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		push_error("SaveManager: negalima atidaryti failo rašymui")
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

# Patogūs metodai — nuskaito/perrašo tik vieną sekciją
func load_section(section: String) -> Dictionary:
	var all = load_all()
	if all.has(section) and all[section] is Dictionary:
		return all[section]
	return {}

func save_section(section: String, data: Dictionary) -> void:
	var all = load_all()
	all[section] = data
	save_all(all)

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
