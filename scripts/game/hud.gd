extends CanvasLayer
class_name HUD

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

func show_brief_message(text: String, duration: float = 1.8) -> void:
	message_label.text = text
	message_time_left = duration

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
	top_bar.offset_bottom = 96.0
	top_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	top_bar.add_theme_constant_override("separation", 18)
	root.add_child(top_bar)

	var left_panel := _make_panel()
	left_panel.custom_minimum_size = Vector2(320.0, 70.0)
	top_bar.add_child(left_panel)
	left_status = _make_status_label(HORIZONTAL_ALIGNMENT_LEFT)
	left_panel.add_child(left_status)

	var center_panel := _make_panel()
	center_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(center_panel)
	center_status = _make_status_label(HORIZONTAL_ALIGNMENT_CENTER)
	center_panel.add_child(center_status)

	var right_panel := _make_panel()
	right_panel.custom_minimum_size = Vector2(320.0, 70.0)
	top_bar.add_child(right_panel)
	right_status = _make_status_label(HORIZONTAL_ALIGNMENT_RIGHT)
	right_panel.add_child(right_status)

	message_label = Label.new()
	message_label.set_anchors_preset(Control.PRESET_CENTER)
	message_label.offset_left = -280.0
	message_label.offset_top = -36.0
	message_label.offset_right = 280.0
	message_label.offset_bottom = 36.0
	message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	message_label.add_theme_font_size_override("font_size", 28)
	root.add_child(message_label)

	footer_label = Label.new()
	footer_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	footer_label.offset_left = 24.0
	footer_label.offset_top = -54.0
	footer_label.offset_right = -24.0
	footer_label.offset_bottom = -18.0
	footer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer_label.add_theme_font_size_override("font_size", 14)
	footer_label.text = "P1: WASD + F/G  |  P2: 方向键 + K/L  |  Esc 暂停  |  R 重开  |  Tab 返回菜单"
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
	pause_panel.custom_minimum_size = Vector2(360.0, 120.0)
	pause_center.add_child(pause_panel)

	var pause_label := Label.new()
	pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pause_label.add_theme_font_size_override("font_size", 28)
	pause_label.text = "已暂停\nEsc 继续，R 重开，Tab 返回菜单"
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
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.custom_minimum_size = Vector2(300.0, 68.0)
	return label

func _update_status_labels() -> void:
	if fighters.size() < 2 or left_status == null:
		return

	left_status.text = _format_fighter_status("P1", fighters[0])
	right_status.text = _format_fighter_status("P2", fighters[1])
	_refresh_mode_text()

func _refresh_mode_text() -> void:
	if center_status == null:
		return
	var mode_text := "训练模式" if training_mode else "本地对战"
	center_status.text = "%s\n按 R 可即时重开" % mode_text

func _format_fighter_status(prefix: String, fighter) -> String:
	var stocks_text := "∞" if training_mode else str(fighter.stocks)
	return "%s  %s\n伤害 %.0f%%   生命 %s" % [
		prefix,
		fighter.display_name,
		fighter.damage_percent,
		stocks_text,
	]
