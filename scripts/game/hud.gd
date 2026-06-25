extends CanvasLayer
class_name HUD

const TuningHub = preload("res://scripts/core/tuning_hub.gd")

var fighters: Array = []
var training_mode := false
var match_over := false
var message_time_left := 0.0

var left_status: Label
var center_status: Label
var right_status: Label
var message_label: Label
var footer_label: Label
var pause_overlay: Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_ui()
	_refresh_mode_text()

func set_training_mode(value: bool) -> void:
	training_mode = value
	if is_node_ready():
		_refresh_mode_text()

func bind_fighters(roster: Array) -> void:
	fighters = roster
	_update_status_labels()

func set_match_over(value: bool) -> void:
	match_over = value

func set_paused(value: bool) -> void:
	if pause_overlay:
		pause_overlay.visible = value

func set_footer_text(text: String) -> void:
	if footer_label:
		footer_label.text = text

func show_brief_message(text: String, duration: float = 1.8, color: Color = Color.WHITE, font_size: int = 28) -> void:
	message_label.text = text
	message_time_left = duration
	message_label.add_theme_color_override("font_color", color)
	message_label.add_theme_font_size_override("font_size", font_size)

func show_combat_callout(event_name: String, details: Dictionary) -> void:
	if event_name == "guard_success":
		show_brief_message(_format_guard_callout(details), 1.0, Color("9ad0ff"), 24)
		return
	if event_name != "hit_landed":
		return

	var color: Color = _message_color_for_hit(details)
	var font_size: int = int(
		TuningHub.HUD_FEEDBACK["training_hit_callout_font_size"]
		if training_mode
		else TuningHub.HUD_FEEDBACK["versus_hit_callout_font_size"]
	)
	var duration: float = float(
		TuningHub.HUD_FEEDBACK["training_hit_callout_duration"]
		if training_mode
		else TuningHub.HUD_FEEDBACK["versus_hit_callout_duration"]
	)
	show_brief_message(_format_hit_callout(details), duration, color, font_size)

func _process(delta: float) -> void:
	_update_status_labels()

	if message_time_left > 0.0 and not match_over:
		message_time_left = max(message_time_left - delta, 0.0)
		if message_time_left == 0.0:
			message_label.text = ""

func _build_ui() -> void:
	var root := Control.new()
	root.name = "Root"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)

	var top_bar := HBoxContainer.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_left = 24.0
	top_bar.offset_top = 20.0
	top_bar.offset_right = -24.0
	top_bar.offset_bottom = 176.0
	top_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	top_bar.add_theme_constant_override("separation", 18)
	root.add_child(top_bar)

	var left_panel := _make_panel()
	left_panel.custom_minimum_size = Vector2(390.0, 152.0)
	top_bar.add_child(left_panel)
	left_status = _make_status_label(HORIZONTAL_ALIGNMENT_LEFT)
	left_panel.add_child(left_status)

	var center_panel := _make_panel()
	center_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(center_panel)
	center_status = _make_status_label(HORIZONTAL_ALIGNMENT_CENTER)
	center_panel.add_child(center_status)

	var right_panel := _make_panel()
	right_panel.custom_minimum_size = Vector2(390.0, 152.0)
	top_bar.add_child(right_panel)
	right_status = _make_status_label(HORIZONTAL_ALIGNMENT_RIGHT)
	right_panel.add_child(right_status)

	message_label = Label.new()
	message_label.set_anchors_preset(Control.PRESET_CENTER)
	message_label.offset_left = -320.0
	message_label.offset_top = -40.0
	message_label.offset_right = 320.0
	message_label.offset_bottom = 40.0
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	message_label.add_theme_font_size_override("font_size", 28)
	root.add_child(message_label)

	footer_label = Label.new()
	footer_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	footer_label.offset_left = 24.0
	footer_label.offset_top = -54.0
	footer_label.offset_right = -24.0
	footer_label.offset_bottom = -18.0
	footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	footer_label.add_theme_font_size_override("font_size", 14)
	footer_label.text = "玩家1：WASD / E / F / G / Q  |  玩家2：方向键 / O / K / L / I  |  Q / I 为必杀，盾牌系偏防御  |  Esc 暂停  |  R 重开  |  Tab 菜单"
	root.add_child(footer_label)

	pause_overlay = Control.new()
	pause_overlay.visible = false
	pause_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(pause_overlay)

	var pause_backdrop := ColorRect.new()
	pause_backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_backdrop.color = Color(0.0, 0.0, 0.0, 0.55)
	pause_overlay.add_child(pause_backdrop)

	var pause_center := CenterContainer.new()
	pause_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_overlay.add_child(pause_center)

	var pause_panel := _make_panel()
	pause_panel.custom_minimum_size = Vector2(420.0, 132.0)
	pause_center.add_child(pause_panel)

	var pause_label := Label.new()
	pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pause_label.add_theme_font_size_override("font_size", 28)
	pause_label.text = "已暂停\nEsc 继续，R 重开，Tab 菜单"
	pause_panel.add_child(pause_label)

func _make_panel() -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color("13212d")
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color("315c73")
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	panel.add_theme_stylebox_override("panel", style)
	return panel

func _make_status_label(alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.horizontal_alignment = alignment
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 14)
	label.custom_minimum_size = Vector2(372.0, 144.0)
	return label

func _update_status_labels() -> void:
	if fighters.size() < 2 or left_status == null:
		return

	left_status.text = _format_fighter_status("玩家1", fighters[0])
	right_status.text = _format_fighter_status("玩家2", fighters[1])
	_refresh_mode_text()

func _refresh_mode_text() -> void:
	if center_status == null:
		return
	if training_mode:
		center_status.text = "训练调试\nR 重开  |  Tab 菜单\n重点观察：状态、招式、命中/受击、回场资源"
		return
	center_status.text = "本地对战\nR 重开  |  Tab 返回菜单"

func _format_fighter_status(prefix: String, fighter) -> String:
	if training_mode:
		return _format_training_fighter_status(prefix, fighter)

	var glide_text := "滑翔中" if fighter.is_gliding else "常规"
	return "%s  %s\n伤害 %.0f%%   命数 %d   跳跃 %d\n状态 %s   招式 %s   %s" % [
		prefix,
		fighter.display_name,
		fighter.damage_percent,
		fighter.stocks,
		fighter.air_jumps_left,
		fighter.get_debug_state_label(),
		fighter.get_current_attack_slot_label(),
		glide_text,
	]

func _format_training_fighter_status(prefix: String, fighter) -> String:
	return "%s  %s\n伤害 %.0f%%  跳跃 %s  闪避 %s\n状态 %s  招式 %s\n标记 %s\n命中 %s\n受击 %s\n%s" % [
		prefix,
		fighter.get_loadout_label(),
		fighter.damage_percent,
		fighter.get_air_jump_count_label(),
		fighter.get_air_dash_count_label(),
		fighter.get_debug_state_label(),
		fighter.get_current_attack_slot_label(),
		fighter.get_debug_flags_label(),
		fighter.get_last_landed_hit_summary(),
		fighter.get_last_received_hit_summary(),
		"%s  %s" % [fighter.get_debug_velocity_label(), fighter.get_debug_timer_label()],
	]

func _format_hit_callout(details: Dictionary) -> String:
	var hit_strength: String = String(details.get("hit_strength", "light"))
	var target_slot: int = int(details.get("other_slot", -1))
	var damage: float = float(details.get("damage", 0.0))
	var target_label := "目标" if target_slot < 0 else "玩家%d" % target_slot
	var prefix: String = "命中"
	if bool(details.get("is_projectile", false)):
		prefix = "射击"
	elif hit_strength == "heavy":
		prefix = "重击"
	elif hit_strength == "medium":
		prefix = "打击"
	return "%s %s  +%.1f  %s" % [
		prefix,
		target_label,
		damage,
		String(details.get("attack_name", details.get("attack_slot", "-"))),
	]

func _format_guard_callout(details: Dictionary) -> String:
	var blocked_from_slot: int = int(details.get("blocked_from_slot", -1))
	var blocked_label := "目标" if blocked_from_slot < 0 else "玩家%d" % blocked_from_slot
	var blocked_attack: String = String(details.get("blocked_attack_name", "攻击"))
	var prefix: String = "反射" if bool(details.get("is_projectile", false)) else "格挡"
	return "%s %s  %s" % [prefix, blocked_label, blocked_attack]

func _message_color_for_hit(details: Dictionary) -> Color:
	if bool(details.get("is_projectile", false)):
		return TuningHub.HUD_FEEDBACK["projectile_hit_color"]

	var hit_strength: String = String(details.get("hit_strength", "light"))
	if hit_strength == "heavy":
		return TuningHub.HUD_FEEDBACK["heavy_hit_color"]
	if hit_strength == "medium":
		return TuningHub.HUD_FEEDBACK["medium_hit_color"]
	return TuningHub.HUD_FEEDBACK["light_hit_color"]
