extends RefCounted
class_name FighterAssembler

const DashConfig = preload("res://scripts/core/dash_config.gd")
const CharacterDatabase = preload("res://scripts/core/character_database.gd")
const WeaponDatabase = preload("res://scripts/core/weapon_database.gd")

static func build_fighter_data(loadout: Dictionary) -> Dictionary:
	var character: Dictionary = CharacterDatabase.get_character(loadout.get("character_id", ""))
	var weapon: Dictionary = WeaponDatabase.get_weapon(loadout.get("weapon_id", ""))
	var jump_count: int = int(character.get("jump_count", 2))
	var dash_config: Dictionary = DashConfig.build(character.get("dash_config_overrides", {}))

	return {
		"id": "%s__%s" % [character.get("id", "fighter"), weapon.get("id", "weapon")],
		"name": "%s / %s" % [character.get("display_name", "角色"), weapon.get("display_name", "武器")],
		"character_name": character.get("display_name", "角色"),
		"weapon_name": weapon.get("display_name", "武器"),
		"primary_color": character.get("primary_color", Color.WHITE),
		"accent_color": character.get("accent_color", Color.WHITE),
		"move_speed": character.get("move_speed", 440.0),
		"air_speed": character.get("air_speed", 390.0),
		"ground_accel": character.get("move_acceleration", 3000.0),
		"ground_friction": character.get("move_brake", 3400.0),
		"air_accel": character.get("air_acceleration", 2200.0),
		"gravity": character.get("gravity", 2500.0),
		"jump_velocity": character.get("jump_velocity", -920.0),
		"double_jump_velocity": character.get("double_jump_velocity", character.get("jump_velocity", -920.0)),
		"max_fall_speed": character.get("max_fall_speed", 1280.0),
		"fast_fall_speed": character.get("fast_fall_speed", 1680.0),
		"max_air_jumps": max(jump_count - 1, 0),
		"coyote_time": character.get("coyote_time", 0.10),
		"jump_buffer": character.get("jump_buffer", 0.12),
		"weight": float(character.get("weight", 1.0)) * float(character.get("knockback_resistance", 1.0)),
		"can_glide": character.get("can_glide", false),
		"glide_fall_speed": character.get("glide_fall_speed", 0.0),
		"glide_horizontal_control": character.get("glide_horizontal_control", 1.0),
		"dash_profile_label": character.get("dash_profile_label", "标准"),
		"dash_config": dash_config,
		"movement_summary": character.get("movement_summary", ""),
		"weapon_family_label": weapon.get("family_label", ""),
		"weapon_role_label": weapon.get("role_label", weapon.get("attack_tempo_label", "")),
		"weapon_range_class": weapon.get("range_class", "中"),
		"weapon_tempo_label": weapon.get("attack_tempo_label", ""),
		"weapon_preview_summary": weapon.get("preview_summary", ""),
		"attacks": weapon.get("attacks", {}).duplicate(true),
		"loadout": loadout.duplicate(true),
	}
