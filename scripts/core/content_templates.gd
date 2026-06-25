extends RefCounted
class_name ContentTemplates

const REQUIRED_CHARACTER_FIELDS: Array[String] = [
	"id",
	"display_name",
	"primary_color",
	"accent_color",
	"move_speed",
	"air_speed",
	"move_acceleration",
	"move_brake",
	"air_acceleration",
	"gravity",
	"jump_count",
	"jump_velocity",
	"double_jump_velocity",
	"max_fall_speed",
	"fast_fall_speed",
	"coyote_time",
	"jump_buffer",
	"can_glide",
	"glide_fall_speed",
	"glide_horizontal_control",
	"weight",
	"knockback_resistance",
	"dash_profile_label",
	"dash_config_overrides",
	"movement_summary",
]

const REQUIRED_WEAPON_FIELDS: Array[String] = [
	"id",
	"display_name",
	"weapon_type",
	"is_ranged",
	"range_class",
	"attack_tempo_label",
	"preview_summary",
	"attacks",
]

const REQUIRED_ATTACK_SLOTS: Array[String] = [
	"light_ground",
	"heavy_ground",
	"up_ground",
	"down_ground",
	"dash_attack",
	"neutral_air",
	"forward_air",
	"up_air",
	"down_air",
	"special_neutral",
	"special_side",
	"special_up",
	"special_down",
]

const REQUIRED_ATTACK_FIELDS: Array[String] = [
	"name",
	"type",
	"startup",
	"active",
	"recovery",
	"movement_scale",
	"damage",
	"base_knockback",
	"knockback_growth",
	"launch_angle",
	"hitstun",
	"hitbox_offset",
	"hitbox_size",
	"lunge",
]

static func build_character_template(character_id: String = "new_character") -> Dictionary:
	return {
		"id": character_id,
		"display_name": "New Character",
		"primary_color": Color("8ecae6"),
		"accent_color": Color("ffb703"),
		"move_speed": 440.0,
		"air_speed": 390.0,
		"move_acceleration": 3000.0,
		"move_brake": 3400.0,
		"air_acceleration": 2200.0,
		"gravity": 2500.0,
		"jump_count": 2,
		"jump_velocity": -920.0,
		"double_jump_velocity": -900.0,
		"max_fall_speed": 1280.0,
		"fast_fall_speed": 1680.0,
		"coyote_time": 0.10,
		"jump_buffer": 0.12,
		"can_glide": false,
		"glide_fall_speed": 0.0,
		"glide_horizontal_control": 1.0,
		"weight": 1.0,
		"knockback_resistance": 1.0,
		"dash_profile_label": "Standard Dash",
		"dash_config_overrides": {},
		"movement_summary": "Describe why this character feels different in motion.",
	}

static func build_weapon_template(weapon_id: String = "new_weapon", weapon_type: String = "melee") -> Dictionary:
	var attacks: Dictionary = {}
	var default_attack_type: String = "projectile" if weapon_type == "ranged" else "melee"
	for slot_name in REQUIRED_ATTACK_SLOTS:
		attacks[slot_name] = build_attack_template(slot_name.replace("_", " "), default_attack_type)

	return {
		"id": weapon_id,
		"display_name": "New Weapon",
		"weapon_type": weapon_type,
		"is_ranged": weapon_type == "ranged",
		"range_class": "mid",
		"attack_tempo_label": "Balanced Tempo",
		"preview_summary": "Describe spacing, pacing, and the weapon's core match role.",
		"attacks": attacks,
	}

static func build_attack_template(attack_name: String = "New Attack", attack_type: String = "melee") -> Dictionary:
	var attack := {
		"name": attack_name,
		"type": attack_type,
		"startup": 0.12,
		"active": 0.08,
		"recovery": 0.18,
		"movement_scale": 0.40,
		"damage": 7.0,
		"base_knockback": 480.0,
		"knockback_growth": 5.4,
		"launch_angle": 30.0,
		"hitstun": 0.16,
		"hitbox_offset": Vector2(64.0, 0.0),
		"hitbox_size": Vector2(72.0, 32.0),
		"lunge": 12.0,
	}

	if attack_type == "projectile":
		attack["projectile_speed"] = 920.0
		attack["projectile_lifetime"] = 0.9

	return attack

static func validate_character_entry(entry: Dictionary) -> Array[String]:
	var issues: Array[String] = []
	for field_name in REQUIRED_CHARACTER_FIELDS:
		if not _has_meaningful_value(entry, field_name):
			issues.append("Missing character field: %s" % field_name)
	return issues

static func validate_weapon_entry(entry: Dictionary) -> Array[String]:
	var issues: Array[String] = []
	for field_name in REQUIRED_WEAPON_FIELDS:
		if not _has_meaningful_value(entry, field_name):
			issues.append("Missing weapon field: %s" % field_name)

	var attacks: Dictionary = entry.get("attacks", {})
	for slot_name in REQUIRED_ATTACK_SLOTS:
		if not attacks.has(slot_name):
			issues.append("Missing attack slot: %s" % slot_name)
			continue
		issues.append_array(validate_attack_entry(slot_name, attacks[slot_name]))
	return issues

static func validate_attack_entry(slot_name: String, attack_entry: Dictionary) -> Array[String]:
	var issues: Array[String] = []
	for field_name in REQUIRED_ATTACK_FIELDS:
		if not _has_meaningful_value(attack_entry, field_name):
			issues.append("%s missing field: %s" % [slot_name, field_name])

	if String(attack_entry.get("type", "melee")) == "projectile":
		if not _has_meaningful_value(attack_entry, "projectile_speed"):
			issues.append("%s missing field: projectile_speed" % slot_name)
		if not _has_meaningful_value(attack_entry, "projectile_lifetime"):
			issues.append("%s missing field: projectile_lifetime" % slot_name)

	return issues

static func _has_meaningful_value(entry: Dictionary, field_name: String) -> bool:
	if not entry.has(field_name):
		return false

	var value = entry[field_name]
	if value is String:
		return String(value) != ""
	return value != null
