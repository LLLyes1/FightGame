extends RefCounted
class_name CharacterDatabase

static func list_characters() -> Array[Dictionary]:
	return [
		{
			"id": "vanguard",
			"display_name": "先锋格斗家",
			"primary_color": Color("f95738"),
			"accent_color": Color("faf0ca"),
			"move_speed": 460.0,
			"air_speed": 400.0,
			"move_acceleration": 3100.0,
			"move_brake": 3600.0,
			"air_acceleration": 2300.0,
			"gravity": 2550.0,
			"jump_count": 2,
			"jump_velocity": -940.0,
			"double_jump_velocity": -900.0,
			"max_fall_speed": 1280.0,
			"fast_fall_speed": 1700.0,
			"coyote_time": 0.10,
			"jump_buffer": 0.12,
			"can_glide": false,
			"glide_fall_speed": 0.0,
			"glide_horizontal_control": 1.0,
			"weight": 1.0,
			"knockback_resistance": 1.0,
			"dash_profile_label": "标准闪避",
			"dash_config_overrides": {
				"dashSpeed": 820.0,
				"dashAcceleration": 5800.0,
				"dashBrake": 6400.0,
				"airDashSpeedMultiplier": 1.12,
				"airDashGravityScale": 0.10,
			},
			"movement_summary": "标准地面对抗，二段跳稳定，回场不偏科。",
		},
		{
			"id": "sky_drifter",
			"display_name": "天翔旅者",
			"primary_color": Color("4ea5d9"),
			"accent_color": Color("f4f1bb"),
			"move_speed": 435.0,
			"air_speed": 440.0,
			"move_acceleration": 2950.0,
			"move_brake": 3250.0,
			"air_acceleration": 2550.0,
			"gravity": 2140.0,
			"jump_count": 3,
			"jump_velocity": -900.0,
			"double_jump_velocity": -860.0,
			"max_fall_speed": 1180.0,
			"fast_fall_speed": 1540.0,
			"coyote_time": 0.11,
			"jump_buffer": 0.14,
			"can_glide": true,
			"glide_fall_speed": 210.0,
			"glide_horizontal_control": 1.18,
			"weight": 0.90,
			"knockback_resistance": 0.92,
			"dash_profile_label": "轻灵闪避",
			"dash_config_overrides": {
				"dashSpeed": 760.0,
				"dashAcceleration": 5200.0,
				"dashBrake": 5600.0,
				"airDashSpeedMultiplier": 1.20,
				"airDashGravityScale": 0.06,
				"allowAirDash": true,
				"maxAirDashes": 1,
			},
			"movement_summary": "三段跳加滑翔，空中修正强，擅长拉扯和回场。",
		},
		{
			"id": "bastion",
			"display_name": "堡垒守卫",
			"primary_color": Color("465362"),
			"accent_color": Color("f6bd60"),
			"move_speed": 400.0,
			"air_speed": 355.0,
			"move_acceleration": 2700.0,
			"move_brake": 3800.0,
			"air_acceleration": 1950.0,
			"gravity": 2760.0,
			"jump_count": 2,
			"jump_velocity": -890.0,
			"double_jump_velocity": -845.0,
			"max_fall_speed": 1360.0,
			"fast_fall_speed": 1780.0,
			"coyote_time": 0.09,
			"jump_buffer": 0.12,
			"can_glide": false,
			"glide_fall_speed": 0.0,
			"glide_horizontal_control": 1.0,
			"weight": 1.28,
			"knockback_resistance": 1.15,
			"dash_profile_label": "重甲闪避",
			"dash_config_overrides": {
				"dashSpeed": 720.0,
				"dashAcceleration": 4700.0,
				"dashBrake": 6900.0,
				"airDashSpeedMultiplier": 1.04,
				"airDashGravityScale": 0.14,
				"startupFrames": 5,
				"recoveryFrames": 8,
				"attackCancelStartFrame": 7,
				"attackCancelEndFrame": 15,
			},
			"movement_summary": "重型压阵角色，承伤强，回场更短但保留基本修正空间。",
		},
	]

static func get_character(character_id: String) -> Dictionary:
	for entry in list_characters():
		if entry.get("id", "") == character_id:
			return entry.duplicate(true)
	return list_characters()[0].duplicate(true)

static func get_character_ids() -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray()
	for entry in list_characters():
		ids.append(entry.get("id", ""))
	return ids
