extends RefCounted
class_name FighterCatalog

const CharacterDatabase = preload("res://scripts/core/character_database.gd")
const WeaponDatabase = preload("res://scripts/core/weapon_database.gd")
const FighterLoadout = preload("res://scripts/core/fighter_loadout.gd")
const FighterAssembler = preload("res://scripts/core/fighter_assembler.gd")

static func list_characters() -> Array[Dictionary]:
	return CharacterDatabase.list_characters()

static func list_weapons() -> Array[Dictionary]:
	return WeaponDatabase.list_weapons()

static func default_loadouts() -> Array[Dictionary]:
	return [
		FighterLoadout.build(1, "vanguard", "saber"),
		FighterLoadout.build(2, "sky_drifter", "hand_cannon"),
	]

static func build_runtime_fighter(loadout: Dictionary) -> Dictionary:
	return FighterAssembler.build_fighter_data(loadout)
