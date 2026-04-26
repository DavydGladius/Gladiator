extends "res://addons/gut/test.gd"

var StaticRuleNoDebugPrints = preload("res://scripts/tools/static_rule_no_debug_prints.gd")

func test_rule_finds_debug_print_calls_in_scripts():
	var rule = StaticRuleNoDebugPrints.new()
	var violations = rule.scan_paths(["res://scripts"])

	print("\n=== NoDebugPrintsInProductionScripts radiniai ===")
	if violations.is_empty():
		print("Radiniu nerasta.")
	else:
		for violation in violations:
			print("- %s:%s" % [violation.path, violation.line])
			print("  Kodas: %s" % [violation.code])
			print("  Komentaras: %s" % [violation.comment])
	print("=== Radiniu pabaiga ===\n")

	assert_true(violations.size() > 0, "Rule should detect at least one debug print call in current scripts.")

	var has_player_violation = false
	for violation in violations:
		if String(violation.path) == "res://scripts/player/Player.gd":
			has_player_violation = true
			break

	assert_true(has_player_violation, "Rule should report debug prints from Player.gd.")
