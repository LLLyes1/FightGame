extends Node2D

signal exit_to_menu
signal match_finished(result_text)

const InputConfig = preload("res://scripts/core/input_config.gd")
const FighterLoadout = preload("res://scripts/core/fighter_loadout.gd")
const FighterAssembler = preload("res://scripts/core/fighter_assembler.gd")
const Fighter = preload("res://scripts/actors/fighter.gd")
const Projectile = preload("res://scripts/actors/projectile.gd")
const Stage = preload("res://scripts/game/stage.gd")
const HUD = preload("res://scripts/game/hud.gd")
const TuningHub = preload("res://scripts/core/tuning_hub.gd")

var start_mode := "versus"
var selected_loadouts: Array[Dictionary] = []
var training_mode := false
var paused := false
var match_over := false
var session_id := 0

var stage: Stage
var hud: HUD
var camera_node: Camera2D
var projectiles_root: Node2D
var fighters: Array = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	InputConfig.ensure_actions()
	training_mode = start_mode == "training"
	_build_scene()
	_start_match()

func _build_scene() -> void:
	stage = Stage.new()
	add_child(stage)

	projectiles_root = Node2D.new()
	projectiles_root.name = "Projectiles"
	add_child(projectiles_root)

	camera_node = Camera2D.new()
	camera_node.enabled = true
	camera_node.position_smoothing_enabled = true
	camera_node.position_smoothing_speed = float(TuningHub.CAMERA["position_smoothing_speed"])
	add_child(camera_node)
	camera_node.make_current()

	hud = HUD.new()
	add_child(hud)
	hud.set_training_mode(training_mode)
	if training_mode:
		hud.set_footer_text("玩家1：WASD / E / F / G / Q  |  玩家2：方向键 / O / K / L / I  |  训练重点：状态、招式、格挡/命中、回场资源")
	else:
		hud.set_footer_text("玩家1：WASD / E / F / G / Q  |  玩家2：方向键 / O / K / L / I  |  上下 + 轻/重攻击 = 地面变体  |  方向 + 必杀 = 方向必杀")

func _start_match() -> void:
	session_id += 1
	paused = false
	match_over = false
	get_tree().paused = false
	hud.set_paused(false)
	hud.set_training_mode(training_mode)
	hud.set_match_over(false)
	var intro_text := "开始战斗"
	if training_mode:
		intro_text = "训练模式\n优先确认状态、招式和回场资源"
	hud.show_brief_message(
		intro_text,
		float(TuningHub.MATCH_FLOW["fight_start_duration"]),
		TuningHub.HUD_FEEDBACK["fight_start_color"],
		int(TuningHub.HUD_FEEDBACK["fight_start_font_size"])
	)

	for fighter in fighters:
		if is_instance_valid(fighter):
			fighter.queue_free()
	fighters.clear()

	for child in projectiles_root.get_children():
		child.queue_free()

	var stock_count: int = 99 if training_mode else 3
	var fighter_setups: Array[Dictionary] = []
	var loadouts: Array[Dictionary] = selected_loadouts if not selected_loadouts.is_empty() else _build_default_loadouts()

	for loadout in loadouts:
		var player_slot: int = int(loadout.get("player_slot", fighter_setups.size() + 1))
		fighter_setups.append({
			"data": FighterAssembler.build_fighter_data(loadout),
			"input": "p%d" % player_slot,
			"spawn": stage.get_spawn_point(clampi(player_slot - 1, 0, 1)),
			"slot": player_slot,
		})

	for index in range(fighter_setups.size()):
		var setup: Dictionary = fighter_setups[index]
		var fighter: Fighter = Fighter.new()
		add_child(fighter)
		fighter.configure(setup["data"], setup["input"], setup["spawn"], int(setup["slot"]), stock_count, training_mode)
		fighter.projectile_requested.connect(_on_projectile_requested)
		fighter.combat_feedback.connect(_on_combat_feedback)
		fighters.append(fighter)

	hud.bind_fighters(fighters)

func _build_default_loadouts() -> Array[Dictionary]:
	return [
		FighterLoadout.build(1, "vanguard", "saber"),
		FighterLoadout.build(2, "sky_drifter", "hand_cannon"),
	]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("return_to_menu"):
		_return_to_menu()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("reset_match"):
		_start_match()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("pause_match") and not match_over:
		paused = not paused
		get_tree().paused = paused
		hud.set_paused(paused)
		get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	if paused:
		return

	_check_ring_outs()
	_update_camera(delta)

func _check_ring_outs() -> void:
	for fighter in fighters:
		if fighter.is_out_of_play():
			continue
		if stage.is_inside_blast_zone(fighter.global_position):
			continue
		_handle_ring_out(fighter)

func _handle_ring_out(fighter: Fighter) -> void:
	if fighter.is_out_of_play():
		return

	fighter.disable_for_ring_out()

	if training_mode:
		hud.show_brief_message(
			"%s 已重置到出生点" % fighter.display_name,
			float(TuningHub.MATCH_FLOW["training_reset_duration"]),
			TuningHub.HUD_FEEDBACK["training_reset_color"],
			int(TuningHub.HUD_FEEDBACK["training_reset_font_size"])
		)
		_respawn_after_delay(fighter, session_id, float(TuningHub.MATCH_FLOW["training_reset_respawn_delay"]))
		return

	fighter.stocks = max(fighter.stocks - 1, 0)
	if fighter.stocks <= 0:
		var winner: Fighter = _find_other_fighter(fighter)
		_finish_match(winner, fighter)
	else:
		hud.show_brief_message(
			"%s 出界 - 剩余 %d 条命" % [fighter.display_name, fighter.stocks],
			float(TuningHub.MATCH_FLOW["ring_out_duration"]),
			TuningHub.HUD_FEEDBACK["ring_out_color"],
			int(TuningHub.HUD_FEEDBACK["ring_out_font_size"])
		)
		_respawn_after_delay(fighter, session_id, float(TuningHub.MATCH_FLOW["ring_out_respawn_delay"]))

func _respawn_after_delay(fighter: Fighter, token: int, delay_seconds: float) -> void:
	await get_tree().create_timer(delay_seconds).timeout
	if token != session_id:
		return
	if match_over:
		return
	if not is_instance_valid(fighter):
		return
	fighter.respawn(stage.get_spawn_point(fighter.player_slot - 1), 1.0)

func _finish_match(winner: Fighter, loser: Fighter) -> void:
	match_over = true
	get_tree().paused = false
	paused = false
	hud.set_paused(false)
	hud.set_match_over(true)

	for fighter in fighters:
		fighter.set_match_active(false)

	var result_text: String = "%s 击败了 %s" % [winner.display_name, loser.display_name]
	hud.show_brief_message(
		"%s\n按 R 重新开始，按 Tab 返回菜单" % result_text,
		float(TuningHub.MATCH_FLOW["match_result_duration"]),
		TuningHub.HUD_FEEDBACK["match_result_color"],
		int(TuningHub.HUD_FEEDBACK["match_result_font_size"])
	)
	match_finished.emit(result_text)

func _find_other_fighter(current_fighter: Fighter) -> Fighter:
	for fighter in fighters:
		if fighter != current_fighter:
			return fighter
	return current_fighter

func _on_projectile_requested(attacker: Fighter, attack_data: Dictionary) -> void:
	if match_over:
		return
	var projectile: Projectile = Projectile.new()
	projectiles_root.add_child(projectile)
	projectile.configure(attacker, attack_data)

func _on_combat_feedback(event_name: String, fighter: Fighter, details: Dictionary) -> void:
	if match_over:
		return
	if not is_instance_valid(hud):
		return
	if not is_instance_valid(fighter):
		return
	if event_name == "hit_landed" or event_name == "guard_success":
		hud.show_combat_callout(event_name, details)

func _update_camera(delta: float) -> void:
	if fighters.is_empty():
		return

	var active_positions: Array[Vector2] = []
	for fighter in fighters:
		if fighter.is_out_of_play():
			continue
		active_positions.append(fighter.global_position)

	if active_positions.is_empty():
		return

	var min_x: float = active_positions[0].x
	var max_x: float = active_positions[0].x
	var min_y: float = active_positions[0].y
	var max_y: float = active_positions[0].y

	for point in active_positions:
		min_x = min(min_x, point.x)
		max_x = max(max_x, point.x)
		min_y = min(min_y, point.y)
		max_y = max(max_y, point.y)

	var midpoint: Vector2 = Vector2((min_x + max_x) * 0.5, (min_y + max_y) * 0.5)
	var camera_zone: Rect2 = stage.get_camera_zone()
	var viewport_size: Vector2 = get_viewport_rect().size
	var camera_margin: Vector2 = TuningHub.CAMERA["margin"]

	var required_width: float = maxf(max_x - min_x + camera_margin.x * 2.0, 1.0)
	var required_height: float = maxf(max_y - min_y + camera_margin.y * 2.0, 1.0)
	var width_zoom: float = viewport_size.x / required_width
	var height_zoom: float = viewport_size.y / required_height
	var zoom_scalar: float = clampf(
		minf(width_zoom, height_zoom),
		float(TuningHub.CAMERA["far_zoom"]),
		float(TuningHub.CAMERA["close_zoom"])
	)
	var target_zoom: Vector2 = Vector2(zoom_scalar, zoom_scalar)

	var half_visible_size: Vector2 = viewport_size / (target_zoom * 2.0)
	var target_position := midpoint

	if camera_zone.size.x <= half_visible_size.x * 2.0:
		target_position.x = camera_zone.get_center().x
	else:
		target_position.x = clampf(
			midpoint.x,
			camera_zone.position.x + half_visible_size.x,
			camera_zone.end.x - half_visible_size.x
		)

	if camera_zone.size.y <= half_visible_size.y * 2.0:
		target_position.y = camera_zone.get_center().y
	else:
		target_position.y = clampf(
			midpoint.y,
			camera_zone.position.y + half_visible_size.y,
			camera_zone.end.y - half_visible_size.y
		)

	camera_node.position = camera_node.position.lerp(
		target_position,
		1.0 - exp(-delta * float(TuningHub.CAMERA["move_lerp_speed"]))
	)
	camera_node.zoom = camera_node.zoom.lerp(
		target_zoom,
		1.0 - exp(-delta * float(TuningHub.CAMERA["zoom_lerp_speed"]))
	)

func _return_to_menu() -> void:
	get_tree().paused = false
	paused = false
	exit_to_menu.emit()
