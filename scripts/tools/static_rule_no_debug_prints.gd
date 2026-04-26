extends RefCounted
class_name StaticRuleNoDebugPrints

var _print_regex := RegEx.new()

func _init() -> void:
	_print_regex.compile("\\bprint\\s*\\(")

func scan_paths(paths: Array) -> Array:
	var violations: Array = []
	for path in paths:
		_scan_path(path, violations)
	return violations

func _scan_path(path: String, violations: Array) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return

	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		if entry.begins_with("."):
			entry = dir.get_next()
			continue

		var full_path := path.path_join(entry)
		if dir.current_is_dir():
			_scan_path(full_path, violations)
		elif entry.ends_with(".gd"):
			_scan_file(full_path, violations)

		entry = dir.get_next()
	dir.list_dir_end()

func _scan_file(file_path: String, violations: Array) -> void:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return

	var line_number := 0
	while not file.eof_reached():
		var line := file.get_line()
		line_number += 1
		if _print_regex.search(line) != null:
			violations.append({
				"path": file_path,
				"line": line_number,
				"code": line.strip_edges()
			})
