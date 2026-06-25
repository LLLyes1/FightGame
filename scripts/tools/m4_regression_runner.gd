extends SceneTree

const GameScene = preload("res://scenes/game/game_scene.tscn")
const CharacterDatabase = preload("res://scripts/core/character_database.gd")
const WeaponDatabase = preload("res://scripts/core/weapon_database.gd")
const FighterLoadout = preload("res://scripts/core/fighter_loadout.gd")
const FighterAssembler = preload("res://scripts/core/fighter_assembler.gd")
const ContentTemplates = preload("res://scripts/core/content_templates.gd")

var failures: Array[String] = []
var versus_pair_count := 0
var training_case_count := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_validate_database_entries()
	_validate_runtime_assembly()
	await _validate_combo_matrix()

	if failures.is_empty():
		print("M4 regression runner passed. Versus pairs: %d, training cases: %d." % [versus_pair_count, training_case_count])
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	print("M4 regression runner failed with %d issues." % failures.size())
	quit(1)

func _validate_database_entries() -> void:
	for character_entry in CharacterDatabase.list_characters():
		var character_issues: Array[String] = ContentTemplates.validate_character_entry(character_entry)
		for issue in character_issues:
			failures.append("%s: %s" % [character_entry.get("id", "unknown_character"), issue])

	for weapon_entry in WeaponDatabase.list_weapons():
		var weapon_issues: Array[String] = ContentTemplates.validate_weapon_entry(weapon_entry)
		for issue in weapon_issues:
			failures.append("%s: %s" % [weapon_entry.get("id", "unknown_weapon"), issue])

func _validate_runtime_assembly() -> void:
	for character_entry in CharacterDatabase.list_characters():
		for weapon_entry in WeaponDatabase.list_weapons():
			var loadout: Dictionary = FighterLoadout.build(1, character_entry["id"], weapon_entry["id"])
			var runtime_data: Dictionary = FighterAssembler.build_fighter_data(loadout)
			if String(runtime_data.get("id", "")) == "":
				failures.append("Runtime assembly missing id for %s + %s" % [character_entry["id"], weapon_entry["id"]])
			if not runtime_data.has("attacks") or Dictionary(runtime_data["attacks"]).is_empty():
				failures.append("Runtime assembly missing attacks for %s + %s" % [character_entry["id"], weapon_entry["id"]])

func _build_all_loadouts() -> Array[Dictionary]:
	var loadouts: Array[Dictionary] = []
	for character_entry in CharacterDatabase.list_characters():
		for weapon_entry in WeaponDatabase.list_weapons():
			loadouts.append({
				"character_id": character_entry["id"],
				"weapon_id": weapon_entry["id"],
			})
	return loadouts

func _describe_loadout(loadout: Dictionary) -> String:
	return "%s + %s" % [loadout["character_id"], loadout["weapon_id"]]

func _validate_scene_boot(mode: String, p1_loadout: Dictionary, p2_loadout: Dictionary) -> void:
	var scene = GameScene.instantiate()
	scene.start_mode = mode
	var selected_loadouts: Array[Dictionary] = [
		FighterLoadout.build(1, p1_loadout["character_id"], p1_loadout["weapon_id"]),
		FighterLoadout.build(2, p2_loadout["character_id"], p2_loadout["weapon_id"]),
	]
	scene.selected_loadouts = selected_loadouts
	root.add_child(scene)

	await process_frame
	await process_frame
	await process_frame

	var label: String = "%s | P1 %s | P2 %s" % [mode, _describe_loadout(p1_loadout), _describe_loadout(p2_loadout)]
	if scene.fighters.size() != 2:
		failures.append("%s booted with %d fighters" % [label, scene.fighters.size()])
	else:
		for fighter in scene.fighters:
			if fighter == null:
				failures.append("%s produced a null fighter" % label)
				continue
			if Dictionary(fighter.fighter_data).is_empty():
				failures.append("%s produced an empty fighter_data payload" % label)
			if not fighter.fighter_data.has("attacks"):
				failures.append("%s missing attacks in fighter_data" % label)
			if mode == "training" and not scene.hud.training_mode:
				failures.append("%s did not enable training HUD mode" % label)

	scene.queue_free()
	await process_frame

func _validate_combo_matrix() -> void:
	var loadouts: Array[Dictionary] = _build_all_loadouts()

	for p1_loadout in loadouts:
		for p2_loadout in loadouts:
			versus_pair_count += 1
			await _validate_scene_boot("versus", p1_loadout, p2_loadout)

	for loadout in loadouts:
		training_case_count += 1
		await _validate_scene_boot(
			"training",
			loadout,
			{"character_id": "vanguard", "weapon_id": "saber"}
		)
