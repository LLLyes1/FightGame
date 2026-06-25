extends Node

const GAME_SCENE = preload("res://scenes/game/game_scene.tscn")
const CharacterDatabase = preload("res://scripts/core/character_database.gd")
const WeaponDatabase = preload("res://scripts/core/weapon_database.gd")
const FighterLoadout = preload("res://scripts/core/fighter_loadout.gd")

var game_root: Node = null
var menu_layer: CanvasLayer = null
var menu_panel: PanelContainer = null
var editor_panel: PanelContainer = null
var summary_panel: PanelContainer = null

var subtitle_label: Label = null
var editor_title_label: Label = null
var editor_hint_label: Label = null
var player_tabs: HBoxContainer = null
var character_cards: GridContainer = null
var weapon_cards: GridContainer = null
var active_player_label: Label = null
var summary_body_label: Label = null
var loadout_matrix_label: Label = null
var roster_info_label: Label = null
var versus_button: Button = null
var training_button: Button = null
var result_label: Label = null
var controls_label: Label = null

var player_tab_buttons: Dictionary = {}
var character_card_buttons: Dictionary = {}
var weapon_card_buttons: Dictionary = {}
var active_editor_player := 1

var character_entries: Array[Dictionary] = []
var weapon_entries: Array[Dictionary] = []

var selected_choices := {
	1: {"character_id": "vanguard", "weapon_id": "saber"},
	2: {"character_id": "sky_drifter", "weapon_id": "hand_cannon"},
}

var current_game = null
var last_result_text := "请先在角色编辑界面中配置角色和武器，然后开始本地对战或训练模式。"

func _ready() -> void:
	game_root = get_node_or_null("GameRoot")
	menu_layer = get_node_or_null("MenuLayer") as CanvasLayer
	menu_panel = get_node_or_null("MenuLayer/Menu/Center/Panel") as PanelContainer
	editor_panel = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/EditorRoot/EditorPanel") as PanelContainer
	summary_panel = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/EditorRoot/SummaryPanel") as PanelContainer
	subtitle_label = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/Subtitle") as Label
	editor_title_label = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/EditorRoot/EditorPanel/EditorMargin/EditorVBox/EditorHeader/EditorTitle") as Label
	editor_hint_label = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/EditorRoot/EditorPanel/EditorMargin/EditorVBox/EditorHeader/EditorHint") as Label
	player_tabs = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/EditorRoot/EditorPanel/EditorMargin/EditorVBox/PlayerTabs") as HBoxContainer
	character_cards = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/EditorRoot/EditorPanel/EditorMargin/EditorVBox/CharacterCards") as GridContainer
	weapon_cards = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/EditorRoot/EditorPanel/EditorMargin/EditorVBox/WeaponCards") as GridContainer
	active_player_label = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/EditorRoot/SummaryPanel/SummaryMargin/SummaryVBox/ActivePlayerLabel") as Label
	summary_body_label = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/EditorRoot/SummaryPanel/SummaryMargin/SummaryVBox/SummaryBody") as Label
	loadout_matrix_label = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/EditorRoot/SummaryPanel/SummaryMargin/SummaryVBox/LoadoutMatrixLabel") as Label
	roster_info_label = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/EditorRoot/SummaryPanel/SummaryMargin/SummaryVBox/RosterInfoLabel") as Label
	versus_button = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/Buttons/VersusButton") as Button
	training_button = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/Buttons/TrainingButton") as Button
	result_label = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/ResultLabel") as Label
	controls_label = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/ControlsLabel") as Label

	if not _has_required_nodes():
		push_error("主菜单结构不完整，请检查 scenes/main/main.tscn。")
		return

	character_entries = CharacterDatabase.list_characters()
	weapon_entries = WeaponDatabase.list_weapons()

	_style_static_panels()
	_setup_static_text()
	_build_loadout_editor()

	versus_button.pressed.connect(_on_start_versus_pressed)
	training_button.pressed.connect(_on_start_training_pressed)
	result_label.text = last_result_text
	_refresh_editor_ui()

func _has_required_nodes() -> bool:
	return (
		game_root != null
		and menu_layer != null
		and menu_panel != null
		and editor_panel != null
		and summary_panel != null
		and subtitle_label != null
		and editor_title_label != null
		and editor_hint_label != null
		and player_tabs != null
		and character_cards != null
		and weapon_cards != null
		and active_player_label != null
		and summary_body_label != null
		and loadout_matrix_label != null
		and roster_info_label != null
		and versus_button != null
		and training_button != null
		and result_label != null
		and controls_label != null
	)

func _style_static_panels() -> void:
	_apply_panel_style(menu_panel, Color("101a24"), Color("315c73"), 16)
	_apply_panel_style(editor_panel, Color("13212d"), Color("3d6d89"), 14)
	_apply_panel_style(summary_panel, Color("10202b"), Color("547d8d"), 14)

func _setup_static_text() -> void:
	subtitle_label.text = "在角色编辑界面中为每位玩家选择角色和武器，再开始本地对战或训练。"
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	editor_title_label.text = "角色编辑器"
	editor_hint_label.text = "步骤 1：切换玩家  步骤 2：选择角色  步骤 3：选择武器"
	editor_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls_label.text = "玩家1：WASD 移动，E 闪避，F 轻攻击，G 重攻击，Q 必杀\n玩家2：方向键移动，O 闪避，K 轻攻击，L 重攻击，I 必杀\n上下 + 轻攻击 = 地面变体，上/下/左右 + 必杀 = 方向必杀，长按跳跃可滑翔。"
	controls_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	loadout_matrix_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	roster_info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	versus_button.text = "开始本地对战"
	training_button.text = "开始训练模式"

func _build_loadout_editor() -> void:
	for child in player_tabs.get_children():
		child.queue_free()
	for child in character_cards.get_children():
		child.queue_free()
	for child in weapon_cards.get_children():
		child.queue_free()

	player_tab_buttons.clear()
	character_card_buttons.clear()
	weapon_card_buttons.clear()

	for player_slot in [1, 2]:
		var tab_button := _make_tab_button(player_slot)
		player_tabs.add_child(tab_button)
		player_tab_buttons[player_slot] = tab_button

	for entry in character_entries:
		var character_id: String = String(entry.get("id", ""))
		var subtitle := "%s | %d 段跳" % [
			String(entry.get("dash_profile_label", "标准")),
			int(entry.get("jump_count", 2))
		]
		var card := _make_choice_card(
			String(entry.get("display_name", "角色")),
			subtitle
		)
		card.tooltip_text = String(entry.get("movement_summary", ""))
		card.pressed.connect(_on_character_card_pressed.bind(character_id))
		character_cards.add_child(card)
		character_card_buttons[character_id] = card

	for entry in weapon_entries:
		var weapon_id: String = String(entry.get("id", ""))
		var subtitle := "%s | %s" % [
			String(entry.get("family_label", "武器")),
			String(entry.get("attack_tempo_label", "标准"))
		]
		var card := _make_choice_card(
			String(entry.get("display_name", "武器")),
			subtitle
		)
		card.tooltip_text = String(entry.get("preview_summary", ""))
		card.pressed.connect(_on_weapon_card_pressed.bind(weapon_id))
		weapon_cards.add_child(card)
		weapon_card_buttons[weapon_id] = card

func _make_tab_button(player_slot: int) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0.0, 78.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 15)
	button.pressed.connect(_on_editor_player_selected.bind(player_slot))
	return button

func _make_choice_card(title: String, subtitle: String) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(0.0, 112.0)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 15)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.text = "%s\n%s" % [title, subtitle]
	button.focus_mode = Control.FOCUS_NONE
	return button

func _on_editor_player_selected(player_slot: int) -> void:
	active_editor_player = player_slot
	_refresh_editor_ui()

func _on_character_card_pressed(character_id: String) -> void:
	selected_choices[active_editor_player]["character_id"] = character_id
	_refresh_editor_ui()

func _on_weapon_card_pressed(weapon_id: String) -> void:
	selected_choices[active_editor_player]["weapon_id"] = weapon_id
	_refresh_editor_ui()

func _on_start_versus_pressed() -> void:
	_launch_game("versus")

func _on_start_training_pressed() -> void:
	_launch_game("training")

func _launch_game(mode: String) -> void:
	if current_game and is_instance_valid(current_game):
		current_game.queue_free()

	current_game = GAME_SCENE.instantiate()
	current_game.start_mode = mode
	current_game.selected_loadouts = _build_selected_loadouts()
	current_game.exit_to_menu.connect(_on_exit_to_menu)
	current_game.match_finished.connect(_on_match_finished)
	game_root.add_child(current_game)
	menu_layer.visible = false

func _on_exit_to_menu() -> void:
	if current_game and is_instance_valid(current_game):
		current_game.queue_free()
	current_game = null
	menu_layer.visible = true
	result_label.text = last_result_text

func _on_match_finished(result_text: String) -> void:
	last_result_text = "%s\n按 Tab 返回菜单，或在对战中按 R 重新开始。" % result_text

func _build_selected_loadouts() -> Array[Dictionary]:
	return [
		FighterLoadout.build(1, selected_choices[1]["character_id"], selected_choices[1]["weapon_id"]),
		FighterLoadout.build(2, selected_choices[2]["character_id"], selected_choices[2]["weapon_id"]),
	]

func _refresh_editor_ui() -> void:
	_refresh_player_tabs()
	_refresh_character_cards()
	_refresh_weapon_cards()
	_refresh_summary_panel()

func _refresh_player_tabs() -> void:
	for player_slot in player_tab_buttons.keys():
		var button: Button = player_tab_buttons[player_slot]
		var character: Dictionary = CharacterDatabase.get_character(selected_choices[player_slot]["character_id"])
		var weapon: Dictionary = WeaponDatabase.get_weapon(selected_choices[player_slot]["weapon_id"])
		var accent: Color = character.get("primary_color", Color("4ea5d9"))
		button.text = "玩家 %d\n%s / %s" % [
			player_slot,
			String(character.get("display_name", "角色")),
			String(weapon.get("display_name", "武器"))
		]
		_apply_choice_button_style(
			button,
			accent,
			player_slot == active_editor_player,
			true
		)

func _refresh_character_cards() -> void:
	for entry in character_entries:
		var character_id: String = String(entry.get("id", ""))
		var button: Button = character_card_buttons.get(character_id)
		if button == null:
			continue

		var selected: bool = selected_choices[active_editor_player]["character_id"] == character_id
		var glide_text: String = "可滑翔" if bool(entry.get("can_glide", false)) else "常规空中"
		var accent: Color = entry.get("primary_color", Color("4ea5d9"))
		button.text = "%s\n%s | %s" % [
			String(entry.get("display_name", "角色")),
			String(entry.get("dash_profile_label", "标准")),
			glide_text
		]
		button.tooltip_text = String(entry.get("movement_summary", ""))
		_apply_choice_button_style(
			button,
			accent,
			selected,
			false
		)

func _refresh_weapon_cards() -> void:
	for entry in weapon_entries:
		var weapon_id: String = String(entry.get("id", ""))
		var button: Button = weapon_card_buttons.get(weapon_id)
		if button == null:
			continue

		var selected: bool = selected_choices[active_editor_player]["weapon_id"] == weapon_id
		button.text = "%s\n%s | %s" % [
			String(entry.get("display_name", "武器")),
			String(entry.get("family_label", "武器")),
			String(entry.get("attack_tempo_label", "标准"))
		]
		button.tooltip_text = String(entry.get("preview_summary", ""))
		_apply_choice_button_style(
			button,
			_get_weapon_accent_color(entry),
			selected,
			false
		)

func _refresh_summary_panel() -> void:
	var active_choice: Dictionary = selected_choices[active_editor_player]
	var active_character: Dictionary = CharacterDatabase.get_character(active_choice["character_id"])
	var active_weapon: Dictionary = WeaponDatabase.get_weapon(active_choice["weapon_id"])
	var jump_count: int = int(active_character.get("jump_count", 2))
	var glide_text: String = "可滑翔" if bool(active_character.get("can_glide", false)) else "不可滑翔"

	active_player_label.text = "正在编辑：玩家 %d" % active_editor_player
	summary_body_label.text = "角色：%s\n角色特点：%s\n机动：%s\n跳跃：%d 段跳 | %s\n\n武器：%s\n武器节奏：%s\n距离：%s\n武器说明：%s" % [
		String(active_character.get("display_name", "角色")),
		String(active_character.get("movement_summary", "")),
		String(active_character.get("dash_profile_label", "标准")),
		jump_count,
		glide_text,
		String(active_weapon.get("display_name", "武器")),
		"%s | %s" % [
			String(active_weapon.get("family_label", "武器")),
			String(active_weapon.get("attack_tempo_label", "标准"))
		],
		String(active_weapon.get("range_class", "中距")),
		String(active_weapon.get("preview_summary", "")),
	]

	loadout_matrix_label.text = "双方当前配置\n玩家 1：%s / %s\n玩家 2：%s / %s" % [
		String(CharacterDatabase.get_character(selected_choices[1]["character_id"]).get("display_name", "角色")),
		String(WeaponDatabase.get_weapon(selected_choices[1]["weapon_id"]).get("display_name", "武器")),
		String(CharacterDatabase.get_character(selected_choices[2]["character_id"]).get("display_name", "角色")),
		String(WeaponDatabase.get_weapon(selected_choices[2]["weapon_id"]).get("display_name", "武器")),
	]

	var total_characters := character_entries.size()
	var total_weapons := weapon_entries.size()
	roster_info_label.text = "当前阵容：%d 名角色 x %d 把武器 = %d 种组合\n建议先在这里完成装配，再进入训练模式熟悉手感。" % [
		total_characters,
		total_weapons,
		total_characters * total_weapons,
	]

func _get_weapon_accent_color(weapon: Dictionary) -> Color:
	match String(weapon.get("id", "")):
		"saber":
			return Color("f95738")
		"hand_cannon":
			return Color("4ea5d9")
		"halberd":
			return Color("f6bd60")
		"shield":
			return Color("8ec07c")
		"pistol":
			return Color("6dc0ff")
		"rifle":
			return Color("4c8fe5")
		"sniper":
			return Color("c792ea")
		_:
			if bool(weapon.get("is_ranged", false)):
				return Color("5da9e9")
			return Color("7cc6a6")

func _apply_panel_style(panel: PanelContainer, background: Color, border: Color, radius: int) -> void:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	panel.add_theme_stylebox_override("panel", style)

func _apply_choice_button_style(button: Button, accent: Color, selected: bool, compact: bool) -> void:
	var base_fill := Color("15232f")
	var fill := base_fill.lerp(accent, 0.24 if selected else 0.10)
	var hover_fill := fill.lerp(Color.WHITE, 0.08)
	var pressed_fill := fill.lerp(Color.BLACK, 0.12)
	var border := accent.lerp(Color.WHITE, 0.10 if selected else 0.02)
	var radius := 16 if compact else 14
	var border_width := 3 if selected else 2

	button.add_theme_stylebox_override("normal", _make_button_style(fill, border, radius, border_width))
	button.add_theme_stylebox_override("hover", _make_button_style(hover_fill, border, radius, border_width))
	button.add_theme_stylebox_override("pressed", _make_button_style(pressed_fill, border, radius, border_width))
	button.add_theme_stylebox_override("focus", _make_button_style(hover_fill, accent, radius, 3))
	button.add_theme_color_override("font_color", Color("f4f7fb"))
	button.add_theme_color_override("font_hover_color", Color("ffffff"))
	button.add_theme_color_override("font_pressed_color", Color("ffffff"))

func _make_button_style(fill: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.content_margin_left = 14.0
	style.content_margin_top = 12.0
	style.content_margin_right = 14.0
	style.content_margin_bottom = 12.0
	return style
