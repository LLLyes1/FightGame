extends RefCounted
class_name WeaponDatabase

static func list_weapons() -> Array[Dictionary]:
	return [
		_build_saber(),
		_build_hand_cannon(),
		_build_halberd(),
		_build_shield(),
		_build_pistol(),
		_build_rifle(),
		_build_sniper(),
	]

static func get_weapon(weapon_id: String) -> Dictionary:
	for entry in list_weapons():
		if entry.get("id", "") == weapon_id:
			return entry.duplicate(true)
	return list_weapons()[0].duplicate(true)

static func get_weapon_ids() -> PackedStringArray:
	var ids: PackedStringArray = PackedStringArray()
	for entry in list_weapons():
		ids.append(entry.get("id", ""))
	return ids

static func _build_saber() -> Dictionary:
	return _weapon_entry(
		"saber",
		"军刀",
		"melee",
		false,
		"近",
		"剑系",
		"贴身快攻",
		"近距离压制武器，确认快，追击直接。",
		{
			"light_ground": _melee_attack("横斩", 0.09, 0.08, 0.14, 0.62, 7.0, 470.0, 5.2, 30.0, 0.16, Vector2(66.0, -4.0), Vector2(86.0, 38.0), 42.0),
			"heavy_ground": _melee_attack("升斩重击", 0.16, 0.10, 0.24, 0.35, 12.0, 610.0, 7.6, 56.0, 0.22, Vector2(72.0, -26.0), Vector2(104.0, 56.0), 24.0),
			"up_ground": _melee_attack("裂空挑", 0.12, 0.08, 0.18, 0.30, 8.0, 520.0, 6.0, 78.0, 0.18, Vector2(10.0, -42.0), Vector2(52.0, 78.0), 12.0),
			"down_ground": _melee_attack("低位切扫", 0.11, 0.09, 0.18, 0.45, 7.5, 420.0, 4.8, 18.0, 0.15, Vector2(62.0, 20.0), Vector2(96.0, 28.0), 18.0),
			"dash_attack": _melee_attack("冲锋斩", 0.08, 0.10, 0.18, 0.18, 9.0, 560.0, 6.6, 24.0, 0.18, Vector2(90.0, -2.0), Vector2(100.0, 34.0), 8.0),
			"neutral_air": _melee_attack("回旋护斩", 0.09, 0.09, 0.16, 0.70, 6.5, 430.0, 4.8, 34.0, 0.14, Vector2(0.0, -6.0), Vector2(86.0, 48.0), 0.0),
			"forward_air": _melee_attack("前空弧斩", 0.10, 0.08, 0.18, 0.68, 8.0, 520.0, 5.6, 24.0, 0.17, Vector2(74.0, -2.0), Vector2(90.0, 34.0), 12.0),
			"up_air": _melee_attack("上空挑斩", 0.11, 0.08, 0.20, 0.58, 7.0, 500.0, 5.9, 82.0, 0.16, Vector2(8.0, -48.0), Vector2(50.0, 86.0), 0.0),
			"down_air": _melee_attack("下劈", 0.12, 0.10, 0.22, 0.52, 9.5, 540.0, 6.2, 290.0, 0.18, Vector2(10.0, 48.0), Vector2(44.0, 92.0), 0.0),
			"special_neutral": _melee_attack("蓄力圆斩", 0.18, 0.10, 0.28, 0.25, 12.0, 620.0, 7.0, 32.0, 0.22, Vector2(82.0, -4.0), Vector2(96.0, 36.0), 26.0),
			"special_side": _melee_attack("踏步突刺", 0.14, 0.09, 0.22, 0.30, 10.0, 560.0, 6.4, 26.0, 0.19, Vector2(88.0, 0.0), Vector2(92.0, 34.0), 20.0),
			"special_up": _melee_attack("旋升斩", 0.14, 0.12, 0.30, 0.28, 10.5, 580.0, 6.6, 86.0, 0.20, Vector2(8.0, -50.0), Vector2(56.0, 96.0), 6.0),
			"special_down": _melee_attack("碎地斩", 0.15, 0.10, 0.24, 0.24, 10.0, 520.0, 5.8, 300.0, 0.18, Vector2(12.0, 44.0), Vector2(50.0, 90.0), 8.0),
		}
	)

static func _build_hand_cannon() -> Dictionary:
	return _weapon_entry(
		"hand_cannon",
		"手炮",
		"ranged",
		true,
		"远",
		"枪械",
		"重射压制",
		"单发收益高、节奏偏重的射击武器，擅长封线和斜角压制。",
		{
			"light_ground": _melee_attack("枪托挥击", 0.10, 0.07, 0.16, 0.55, 6.0, 430.0, 4.8, 24.0, 0.14, Vector2(58.0, 0.0), Vector2(72.0, 34.0), 28.0),
			"heavy_ground": _projectile_attack("爆裂射击", 0.18, 0.04, 0.28, 0.20, 9.0, 560.0, 6.8, 18.0, 0.18, Vector2(78.0, -8.0), Vector2(52.0, 24.0), -34.0, 960.0, 1.0),
			"up_ground": _projectile_attack("上扬抛射", 0.16, 0.04, 0.24, 0.18, 7.5, 500.0, 5.8, 74.0, 0.16, Vector2(24.0, -42.0), Vector2(34.0, 52.0), -12.0, 860.0, 0.9, -58.0),
			"down_ground": _melee_attack("低位枪托", 0.11, 0.08, 0.18, 0.40, 6.5, 400.0, 4.4, 16.0, 0.14, Vector2(54.0, 18.0), Vector2(74.0, 28.0), 14.0),
			"dash_attack": _melee_attack("滑步顶撞", 0.09, 0.09, 0.20, 0.16, 7.0, 460.0, 5.0, 20.0, 0.15, Vector2(78.0, -2.0), Vector2(82.0, 30.0), -8.0),
			"neutral_air": _projectile_attack("空中点射", 0.12, 0.04, 0.20, 0.70, 6.8, 440.0, 5.0, 16.0, 0.14, Vector2(78.0, -6.0), Vector2(36.0, 20.0), -8.0, 920.0, 0.9),
			"forward_air": _projectile_attack("前向爆发", 0.14, 0.04, 0.22, 0.66, 7.8, 500.0, 5.8, 24.0, 0.16, Vector2(82.0, -2.0), Vector2(40.0, 22.0), -10.0, 980.0, 0.9),
			"up_air": _projectile_attack("上空散射", 0.13, 0.04, 0.22, 0.60, 7.0, 520.0, 5.6, 82.0, 0.16, Vector2(8.0, -56.0), Vector2(26.0, 48.0), 0.0, 840.0, 0.8, -74.0),
			"down_air": _projectile_attack("坠落点弹", 0.15, 0.04, 0.24, 0.58, 8.0, 540.0, 6.0, 290.0, 0.17, Vector2(10.0, 50.0), Vector2(28.0, 54.0), 0.0, 900.0, 0.8, 68.0),
			"special_neutral": _projectile_attack("蓄能点弹", 0.20, 0.04, 0.30, 0.15, 11.0, 620.0, 7.2, 18.0, 0.20, Vector2(86.0, -8.0), Vector2(56.0, 28.0), -18.0, 1020.0, 1.0),
			"special_side": _projectile_attack("侧滑射击", 0.16, 0.04, 0.24, 0.18, 8.5, 520.0, 5.9, 20.0, 0.16, Vector2(82.0, -6.0), Vector2(40.0, 22.0), -20.0, 960.0, 0.9),
			"special_up": _projectile_attack("信号弹", 0.18, 0.04, 0.28, 0.16, 8.0, 560.0, 6.1, 84.0, 0.18, Vector2(10.0, -58.0), Vector2(24.0, 52.0), 0.0, 860.0, 0.9, -88.0),
			"special_down": _projectile_attack("落点标记", 0.18, 0.04, 0.26, 0.14, 8.8, 560.0, 6.0, 290.0, 0.18, Vector2(12.0, 54.0), Vector2(28.0, 56.0), 0.0, 920.0, 0.9, 74.0),
		}
	)

static func _build_halberd() -> Dictionary:
	return _weapon_entry(
		"halberd",
		"长戟",
		"melee",
		false,
		"中",
		"长柄",
		"中距控线",
		"长判定控场武器，前方封线和反空更强，但压边风险也更高。",
		{
			"light_ground": _melee_attack("探线刺", 0.11, 0.08, 0.18, 0.46, 7.5, 460.0, 5.0, 24.0, 0.15, Vector2(86.0, -2.0), Vector2(118.0, 36.0), 20.0),
			"heavy_ground": _melee_attack("横劈终结", 0.19, 0.10, 0.32, 0.16, 12.0, 580.0, 6.8, 42.0, 0.21, Vector2(90.0, -18.0), Vector2(118.0, 48.0), 12.0),
			"up_ground": _melee_attack("裂空挑戟", 0.14, 0.09, 0.22, 0.20, 8.2, 500.0, 5.6, 80.0, 0.17, Vector2(14.0, -54.0), Vector2(54.0, 90.0), 2.0),
			"down_ground": _melee_attack("封线横扫", 0.12, 0.09, 0.20, 0.30, 7.8, 430.0, 4.9, 16.0, 0.15, Vector2(84.0, 24.0), Vector2(122.0, 28.0), 10.0),
			"dash_attack": _melee_attack("突进钉入", 0.10, 0.10, 0.22, 0.20, 8.8, 520.0, 5.8, 20.0, 0.17, Vector2(108.0, -4.0), Vector2(126.0, 32.0), 16.0),
			"neutral_air": _melee_attack("回环护戟", 0.12, 0.09, 0.20, 0.58, 7.0, 450.0, 5.1, 34.0, 0.15, Vector2(18.0, -6.0), Vector2(110.0, 56.0), 0.0),
			"forward_air": _melee_attack("前空断线", 0.13, 0.08, 0.22, 0.52, 8.6, 520.0, 5.9, 28.0, 0.17, Vector2(92.0, -2.0), Vector2(116.0, 34.0), 0.0),
			"up_air": _melee_attack("举戟挑空", 0.15, 0.08, 0.24, 0.42, 7.4, 490.0, 5.5, 84.0, 0.16, Vector2(10.0, -60.0), Vector2(50.0, 96.0), 0.0),
			"down_air": _melee_attack("锚坠下压", 0.15, 0.10, 0.24, 0.46, 9.2, 530.0, 6.0, 285.0, 0.18, Vector2(8.0, 54.0), Vector2(46.0, 100.0), 0.0),
			"special_neutral": _melee_attack("破防横压", 0.20, 0.10, 0.30, 0.18, 11.5, 620.0, 7.0, 30.0, 0.22, Vector2(100.0, -2.0), Vector2(130.0, 38.0), 22.0),
			"special_side": _melee_attack("行军突刺", 0.18, 0.10, 0.30, 0.16, 9.6, 530.0, 5.8, 22.0, 0.18, Vector2(104.0, 2.0), Vector2(118.0, 32.0), 12.0),
			"special_up": _melee_attack("立柱上挑", 0.17, 0.12, 0.30, 0.18, 10.0, 570.0, 6.4, 88.0, 0.19, Vector2(14.0, -68.0), Vector2(62.0, 114.0), 6.0),
			"special_down": _melee_attack("锚点压制", 0.17, 0.10, 0.26, 0.18, 9.6, 500.0, 5.6, 300.0, 0.17, Vector2(34.0, 42.0), Vector2(92.0, 74.0), 2.0),
		}
	)

static func _build_shield() -> Dictionary:
	return _weapon_entry(
		"shield",
		"回旋盾",
		"melee",
		true,
		"中",
		"盾牌",
		"攻守切换",
		"普通攻击围绕投出与回收展开，必杀偏防御与反制，适合边控盾轨迹边找反打窗口。",
		{
			"light_ground": _returning_attack("试探掷盾", 0.11, 0.04, 0.22, 0.30, 6.8, 430.0, 4.8, 24.0, 0.15, Vector2(66.0, -4.0), Vector2(42.0, 42.0), 6.0, 820.0, 0.95, 0.18, 760.0),
			"heavy_ground": _returning_attack("重手回旋", 0.17, 0.04, 0.30, 0.16, 9.8, 560.0, 6.2, 30.0, 0.18, Vector2(74.0, -8.0), Vector2(52.0, 52.0), 2.0, 920.0, 1.05, 0.24, 860.0),
			"up_ground": _returning_attack("挑空掷盾", 0.15, 0.04, 0.24, 0.20, 7.4, 500.0, 5.6, 82.0, 0.17, Vector2(22.0, -44.0), Vector2(38.0, 38.0), 0.0, 780.0, 0.95, 0.18, 760.0, -62.0),
			"down_ground": _returning_attack("低位折返", 0.13, 0.04, 0.22, 0.24, 7.0, 420.0, 4.8, 18.0, 0.15, Vector2(68.0, 18.0), Vector2(38.0, 38.0), 0.0, 760.0, 0.95, 0.20, 720.0, 8.0),
			"dash_attack": _melee_attack("冲盾撞击", 0.09, 0.10, 0.22, 0.22, 8.4, 520.0, 5.8, 24.0, 0.17, Vector2(84.0, -2.0), Vector2(86.0, 34.0), 10.0),
			"neutral_air": _returning_attack("空中回环", 0.10, 0.04, 0.18, 0.62, 6.2, 430.0, 4.8, 30.0, 0.14, Vector2(58.0, -2.0), Vector2(36.0, 36.0), 0.0, 800.0, 0.90, 0.16, 760.0),
			"forward_air": _returning_attack("前压折线", 0.12, 0.04, 0.22, 0.56, 7.6, 500.0, 5.6, 24.0, 0.16, Vector2(72.0, -2.0), Vector2(38.0, 38.0), 0.0, 860.0, 0.92, 0.18, 820.0, -8.0),
			"up_air": _melee_attack("护边挑盾", 0.12, 0.08, 0.20, 0.48, 7.0, 480.0, 5.3, 84.0, 0.16, Vector2(12.0, -46.0), Vector2(52.0, 84.0), 0.0),
			"down_air": _melee_attack("盾坠下压", 0.13, 0.10, 0.22, 0.42, 8.6, 520.0, 5.8, 286.0, 0.18, Vector2(10.0, 48.0), Vector2(48.0, 92.0), 0.0),
			"special_neutral": _guard_attack("盾姿格挡", 0.08, 0.06, 0.26, 0.08, 5.0, 380.0, 4.0, 24.0, 0.12, Vector2(48.0, 0.0), Vector2(66.0, 40.0), 0.0, {
				"window_start": 0.04,
				"window_end": 0.24,
				"pushback_speed": 150.0,
				"post_guard_invulnerability": 0.10,
				"projectile_response": "destroy",
			}),
			"special_side": _guard_attack("盾冲推进", 0.12, 0.10, 0.24, 0.18, 8.8, 520.0, 5.6, 20.0, 0.17, Vector2(84.0, 0.0), Vector2(84.0, 36.0), 22.0, {
				"window_start": 0.06,
				"window_end": 0.18,
				"pushback_speed": 180.0,
				"post_guard_invulnerability": 0.08,
				"projectile_response": "destroy",
			}),
			"special_up": _guard_attack("守位升架", 0.13, 0.10, 0.28, 0.16, 8.4, 540.0, 5.9, 86.0, 0.18, Vector2(10.0, -54.0), Vector2(54.0, 96.0), 6.0, {
				"window_start": 0.05,
				"window_end": 0.16,
				"pushback_speed": 170.0,
				"post_guard_invulnerability": 0.08,
				"projectile_response": "destroy",
			}),
			"special_down": _guard_attack("定点反射", 0.10, 0.06, 0.34, 0.02, 4.0, 320.0, 3.2, 22.0, 0.10, Vector2(42.0, 2.0), Vector2(60.0, 46.0), 0.0, {
				"window_start": 0.05,
				"window_end": 0.30,
				"pushback_speed": 120.0,
				"post_guard_invulnerability": 0.12,
				"projectile_response": "reflect",
				"reflect_angle": 0.0,
			}),
		}
	)

static func _build_pistol() -> Dictionary:
	return _weapon_entry(
		"pistol",
		"手枪",
		"ranged",
		true,
		"中远",
		"枪械",
		"机动点射",
		"轻量化枪械，出手快、收招快，适合边走边压和空地衔接点射。",
		{
			"light_ground": _projectile_attack("快点射", 0.09, 0.04, 0.14, 0.62, 5.4, 390.0, 4.0, 18.0, 0.12, Vector2(70.0, -4.0), Vector2(26.0, 16.0), -4.0, 980.0, 0.80),
			"heavy_ground": _projectile_attack("双连点", 0.11, 0.04, 0.20, 0.50, 5.8, 410.0, 4.2, 20.0, 0.12, Vector2(72.0, -6.0), Vector2(26.0, 16.0), -6.0, 980.0, 0.80, 0.0, {
				"projectile_shot_count": 2,
				"projectile_burst_interval": 0.05,
			}),
			"up_ground": _projectile_attack("抬手打空", 0.11, 0.04, 0.18, 0.44, 5.6, 420.0, 4.2, 78.0, 0.13, Vector2(18.0, -44.0), Vector2(24.0, 16.0), -4.0, 920.0, 0.82, -62.0),
			"down_ground": _melee_attack("贴身膝撞", 0.10, 0.08, 0.18, 0.46, 6.6, 430.0, 4.8, 20.0, 0.14, Vector2(56.0, 12.0), Vector2(70.0, 30.0), 14.0),
			"dash_attack": _projectile_attack("滑步点射", 0.10, 0.04, 0.18, 0.34, 5.8, 420.0, 4.3, 18.0, 0.13, Vector2(78.0, -4.0), Vector2(26.0, 16.0), 10.0, 1020.0, 0.78),
			"neutral_air": _projectile_attack("空中速射", 0.09, 0.04, 0.16, 0.72, 5.2, 390.0, 4.0, 16.0, 0.12, Vector2(72.0, -6.0), Vector2(24.0, 16.0), 0.0, 960.0, 0.80),
			"forward_air": _projectile_attack("前空追击", 0.11, 0.04, 0.18, 0.66, 6.0, 450.0, 4.6, 22.0, 0.13, Vector2(76.0, -4.0), Vector2(26.0, 16.0), 0.0, 980.0, 0.82),
			"up_air": _projectile_attack("空中挑射", 0.12, 0.04, 0.18, 0.58, 5.8, 440.0, 4.5, 80.0, 0.14, Vector2(16.0, -56.0), Vector2(22.0, 16.0), 0.0, 920.0, 0.80, -76.0),
			"down_air": _projectile_attack("空中压线", 0.12, 0.04, 0.20, 0.54, 6.2, 460.0, 4.8, 285.0, 0.15, Vector2(10.0, 52.0), Vector2(24.0, 16.0), 0.0, 960.0, 0.82, 70.0),
			"special_neutral": _projectile_attack("连点倾泻", 0.15, 0.04, 0.24, 0.24, 4.8, 380.0, 3.8, 18.0, 0.12, Vector2(78.0, -4.0), Vector2(24.0, 14.0), -2.0, 1020.0, 0.78, 0.0, {
				"projectile_shot_count": 3,
				"projectile_burst_interval": 0.05,
			}),
			"special_side": _projectile_attack("突步追枪", 0.13, 0.04, 0.22, 0.30, 6.8, 460.0, 5.0, 18.0, 0.14, Vector2(82.0, -4.0), Vector2(28.0, 16.0), 18.0, 1040.0, 0.82),
			"special_up": _projectile_attack("腾身警戒", 0.14, 0.04, 0.24, 0.28, 6.0, 470.0, 4.8, 84.0, 0.15, Vector2(12.0, -58.0), Vector2(24.0, 16.0), 8.0, 940.0, 0.82, -82.0),
			"special_down": _projectile_attack("压低火线", 0.14, 0.04, 0.22, 0.18, 6.6, 450.0, 4.8, 26.0, 0.14, Vector2(74.0, 16.0), Vector2(28.0, 16.0), 0.0, 980.0, 0.82, 10.0),
		}
	)

static func _build_rifle() -> Dictionary:
	return _weapon_entry(
		"rifle",
		"步枪",
		"ranged",
		true,
		"远",
		"枪械",
		"持续压制",
		"稳定的中远距离压制武器，擅长用节奏明确的多发射击封住横向线路。",
		{
			"light_ground": _projectile_attack("两连压射", 0.12, 0.04, 0.22, 0.36, 5.2, 400.0, 4.2, 18.0, 0.12, Vector2(82.0, -6.0), Vector2(30.0, 16.0), -6.0, 1040.0, 0.86, 0.0, {
				"projectile_shot_count": 2,
				"projectile_burst_interval": 0.06,
			}),
			"heavy_ground": _projectile_attack("三连封线", 0.16, 0.04, 0.28, 0.20, 5.8, 430.0, 4.6, 20.0, 0.13, Vector2(86.0, -6.0), Vector2(30.0, 16.0), -10.0, 1080.0, 0.90, 0.0, {
				"projectile_shot_count": 3,
				"projectile_burst_interval": 0.05,
			}),
			"up_ground": _projectile_attack("抬枪反空", 0.14, 0.04, 0.24, 0.18, 5.6, 430.0, 4.5, 80.0, 0.14, Vector2(22.0, -48.0), Vector2(28.0, 16.0), -4.0, 980.0, 0.88, -54.0, {
				"projectile_shot_count": 2,
				"projectile_burst_interval": 0.06,
			}),
			"down_ground": _projectile_attack("低姿压线", 0.13, 0.04, 0.20, 0.22, 5.4, 400.0, 4.2, 14.0, 0.12, Vector2(82.0, 18.0), Vector2(32.0, 16.0), 0.0, 1040.0, 0.86, 6.0),
			"dash_attack": _melee_attack("枪托顶开", 0.10, 0.08, 0.22, 0.18, 7.4, 470.0, 5.0, 22.0, 0.15, Vector2(82.0, -2.0), Vector2(84.0, 32.0), 12.0),
			"neutral_air": _projectile_attack("空中稳射", 0.12, 0.04, 0.20, 0.58, 5.0, 390.0, 4.0, 18.0, 0.12, Vector2(80.0, -6.0), Vector2(28.0, 16.0), 0.0, 1000.0, 0.84),
			"forward_air": _projectile_attack("前空截击", 0.13, 0.04, 0.22, 0.52, 5.8, 430.0, 4.5, 22.0, 0.13, Vector2(84.0, -4.0), Vector2(30.0, 16.0), 0.0, 1040.0, 0.86),
			"up_air": _projectile_attack("空中抬压", 0.14, 0.04, 0.22, 0.48, 5.6, 430.0, 4.4, 82.0, 0.14, Vector2(18.0, -58.0), Vector2(28.0, 16.0), 0.0, 980.0, 0.86, -70.0),
			"down_air": _projectile_attack("空中垂压", 0.14, 0.04, 0.22, 0.46, 6.0, 450.0, 4.8, 286.0, 0.15, Vector2(10.0, 56.0), Vector2(28.0, 16.0), 0.0, 980.0, 0.86, 72.0),
			"special_neutral": _projectile_attack("站桩压制", 0.18, 0.04, 0.32, 0.06, 5.0, 390.0, 4.0, 18.0, 0.12, Vector2(88.0, -6.0), Vector2(30.0, 16.0), 0.0, 1100.0, 0.92, 0.0, {
				"projectile_shot_count": 4,
				"projectile_burst_interval": 0.05,
			}),
			"special_side": _projectile_attack("推进扫射", 0.16, 0.04, 0.30, 0.18, 5.4, 410.0, 4.2, 20.0, 0.13, Vector2(86.0, -6.0), Vector2(30.0, 16.0), 18.0, 1060.0, 0.90, 0.0, {
				"projectile_shot_count": 3,
				"projectile_burst_interval": 0.05,
			}),
			"special_up": _projectile_attack("抬枪开路", 0.17, 0.04, 0.28, 0.16, 5.8, 450.0, 4.8, 84.0, 0.15, Vector2(18.0, -60.0), Vector2(28.0, 16.0), 4.0, 980.0, 0.90, -78.0, {
				"projectile_shot_count": 2,
				"projectile_burst_interval": 0.06,
			}),
			"special_down": _projectile_attack("蹲姿封锁", 0.16, 0.04, 0.28, 0.08, 5.4, 420.0, 4.4, 18.0, 0.13, Vector2(84.0, 18.0), Vector2(30.0, 16.0), 0.0, 1080.0, 0.90, 4.0, {
				"projectile_shot_count": 3,
				"projectile_burst_interval": 0.06,
			}),
		}
	)

static func _build_sniper() -> Dictionary:
	return _weapon_entry(
		"sniper",
		"狙击枪",
		"ranged",
		true,
		"超远",
		"枪械",
		"高承诺狙击",
		"高前摇、高回报的精确射击武器，适合抓对手大动作或远距离换血窗口。",
		{
			"light_ground": _projectile_attack("快瞄射击", 0.16, 0.04, 0.24, 0.24, 7.2, 500.0, 5.4, 18.0, 0.15, Vector2(90.0, -8.0), Vector2(36.0, 16.0), -8.0, 1320.0, 1.05),
			"heavy_ground": _projectile_attack("重型贯射", 0.26, 0.04, 0.34, 0.08, 11.5, 640.0, 7.2, 22.0, 0.22, Vector2(96.0, -8.0), Vector2(40.0, 18.0), -6.0, 1440.0, 1.10),
			"up_ground": _projectile_attack("挑空狙击", 0.20, 0.04, 0.28, 0.10, 8.2, 560.0, 6.0, 86.0, 0.17, Vector2(22.0, -56.0), Vector2(34.0, 16.0), -4.0, 1260.0, 1.05, -68.0),
			"down_ground": _melee_attack("贴身枪托", 0.11, 0.08, 0.20, 0.38, 7.2, 450.0, 4.8, 18.0, 0.14, Vector2(58.0, 14.0), Vector2(78.0, 30.0), 10.0),
			"dash_attack": _melee_attack("滑步顶枪", 0.10, 0.08, 0.22, 0.16, 7.6, 480.0, 5.0, 22.0, 0.15, Vector2(86.0, -2.0), Vector2(86.0, 32.0), 12.0),
			"neutral_air": _projectile_attack("空中快镜", 0.15, 0.04, 0.20, 0.52, 6.6, 460.0, 4.8, 20.0, 0.14, Vector2(84.0, -8.0), Vector2(32.0, 16.0), 0.0, 1260.0, 1.00),
			"forward_air": _projectile_attack("前空追狙", 0.18, 0.04, 0.22, 0.46, 8.4, 560.0, 6.0, 24.0, 0.17, Vector2(88.0, -8.0), Vector2(34.0, 16.0), 0.0, 1340.0, 1.04),
			"up_air": _projectile_attack("上空探镜", 0.18, 0.04, 0.24, 0.40, 7.4, 520.0, 5.6, 84.0, 0.16, Vector2(18.0, -60.0), Vector2(32.0, 16.0), 0.0, 1280.0, 1.02, -76.0),
			"down_air": _projectile_attack("俯角狙落", 0.18, 0.04, 0.24, 0.40, 8.0, 540.0, 5.8, 288.0, 0.17, Vector2(12.0, 58.0), Vector2(32.0, 16.0), 0.0, 1300.0, 1.02, 76.0),
			"special_neutral": _projectile_attack("贯穿瞄射", 0.30, 0.04, 0.38, 0.02, 13.0, 700.0, 7.8, 20.0, 0.24, Vector2(98.0, -8.0), Vector2(44.0, 18.0), 0.0, 1520.0, 1.14),
			"special_side": _projectile_attack("撤步狙击", 0.22, 0.04, 0.30, 0.10, 9.6, 600.0, 6.6, 18.0, 0.18, Vector2(94.0, -8.0), Vector2(38.0, 18.0), -20.0, 1420.0, 1.10),
			"special_up": _projectile_attack("天穹照准", 0.24, 0.04, 0.32, 0.08, 9.2, 620.0, 6.6, 88.0, 0.19, Vector2(20.0, -62.0), Vector2(36.0, 18.0), 6.0, 1360.0, 1.08, -84.0),
			"special_down": _projectile_attack("低伏猎点", 0.22, 0.04, 0.30, 0.04, 9.0, 600.0, 6.4, 24.0, 0.18, Vector2(92.0, 18.0), Vector2(38.0, 18.0), 0.0, 1420.0, 1.08, 8.0),
		}
	)

static func _weapon_entry(
	weapon_id: String,
	display_name: String,
	weapon_type: String,
	is_ranged: bool,
	range_class: String,
	family_label: String,
	attack_tempo_label: String,
	preview_summary: String,
	attacks: Dictionary,
	role_label: String = ""
) -> Dictionary:
	return {
		"id": weapon_id,
		"display_name": display_name,
		"weapon_type": weapon_type,
		"is_ranged": is_ranged,
		"range_class": range_class,
		"family_label": family_label,
		"role_label": role_label if role_label != "" else attack_tempo_label,
		"attack_tempo_label": attack_tempo_label,
		"preview_summary": preview_summary,
		"attacks": attacks,
	}

static func _melee_attack(
	name: String,
	startup: float,
	active: float,
	recovery: float,
	movement_scale: float,
	damage: float,
	base_knockback: float,
	knockback_growth: float,
	launch_angle: float,
	hitstun: float,
	hitbox_offset: Vector2,
	hitbox_size: Vector2,
	lunge: float
) -> Dictionary:
	return {
		"name": name,
		"type": "melee",
		"startup": startup,
		"active": active,
		"recovery": recovery,
		"movement_scale": movement_scale,
		"damage": damage,
		"base_knockback": base_knockback,
		"knockback_growth": knockback_growth,
		"launch_angle": launch_angle,
		"hitstun": hitstun,
		"hitbox_offset": hitbox_offset,
		"hitbox_size": hitbox_size,
		"lunge": lunge,
	}

static func _projectile_attack(
	name: String,
	startup: float,
	active: float,
	recovery: float,
	movement_scale: float,
	damage: float,
	base_knockback: float,
	knockback_growth: float,
	launch_angle: float,
	hitstun: float,
	hitbox_offset: Vector2,
	hitbox_size: Vector2,
	lunge: float,
	projectile_speed: float,
	projectile_lifetime: float,
	projectile_angle: float = 0.0,
	extra: Dictionary = {}
) -> Dictionary:
	var attack: Dictionary = _melee_attack(
		name,
		startup,
		active,
		recovery,
		movement_scale,
		damage,
		base_knockback,
		knockback_growth,
		launch_angle,
		hitstun,
		hitbox_offset,
		hitbox_size,
		lunge
	)
	attack["type"] = "projectile"
	attack["projectile_speed"] = projectile_speed
	attack["projectile_lifetime"] = projectile_lifetime
	attack["projectile_angle"] = projectile_angle
	return _merge_attack_options(attack, extra)

static func _returning_attack(
	name: String,
	startup: float,
	active: float,
	recovery: float,
	movement_scale: float,
	damage: float,
	base_knockback: float,
	knockback_growth: float,
	launch_angle: float,
	hitstun: float,
	hitbox_offset: Vector2,
	hitbox_size: Vector2,
	lunge: float,
	projectile_speed: float,
	projectile_lifetime: float,
	return_delay: float,
	return_speed: float,
	projectile_angle: float = 0.0,
	extra: Dictionary = {}
) -> Dictionary:
	var returning_options: Dictionary = {
		"projectile_behavior": "returning",
		"return_delay": return_delay,
		"return_speed": return_speed,
		"can_hit_on_return": true,
		"catch_radius": 44.0,
	}
	for key in extra.keys():
		returning_options[key] = extra[key]
	return _projectile_attack(
		name,
		startup,
		active,
		recovery,
		movement_scale,
		damage,
		base_knockback,
		knockback_growth,
		launch_angle,
		hitstun,
		hitbox_offset,
		hitbox_size,
		lunge,
		projectile_speed,
		projectile_lifetime,
		projectile_angle,
		returning_options
	)

static func _guard_attack(
	name: String,
	startup: float,
	active: float,
	recovery: float,
	movement_scale: float,
	damage: float,
	base_knockback: float,
	knockback_growth: float,
	launch_angle: float,
	hitstun: float,
	hitbox_offset: Vector2,
	hitbox_size: Vector2,
	lunge: float,
	guard_profile: Dictionary,
	extra: Dictionary = {}
) -> Dictionary:
	var attack: Dictionary = _melee_attack(
		name,
		startup,
		active,
		recovery,
		movement_scale,
		damage,
		base_knockback,
		knockback_growth,
		launch_angle,
		hitstun,
		hitbox_offset,
		hitbox_size,
		lunge
	)
	attack["guard_profile"] = guard_profile.duplicate(true)
	return _merge_attack_options(attack, extra)

static func _merge_attack_options(attack: Dictionary, extra: Dictionary) -> Dictionary:
	for key in extra.keys():
		attack[key] = extra[key]
	return attack
