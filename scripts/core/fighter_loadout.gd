extends RefCounted
class_name FighterLoadout

static func build(player_slot: int, character_id: String, weapon_id: String, skin_id: String = "default", color_id: String = "default") -> Dictionary:
	return {
		"player_slot": player_slot,
		"character_id": character_id,
		"weapon_id": weapon_id,
		"skin_id": skin_id,
		"color_id": color_id,
	}
