extends CharacterBody2D
class_name Fighter

signal projectile_requested(attacker, attack_data)
signal dash_event(event_name, fighter, details)
signal combat_feedback(event_name, fighter, details)

const DashConfig = preload("res://scripts/core/dash_config.gd")
const TuningHub = preload("res://scripts/core/tuning_hub.gd")

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
	LAND,
	ATTACK,
	HURT,
	DASH_STARTUP,
	DASH_TRAVEL,
	DASH_RECOVERY,
	DEAD,
}

const BODY_SIZE := Vector2(54.0, 96.0)
const AIR_DRAG := 900.0
const FRAME_DURATION := 1.0 / 60.0
const LAND_STATE_DURATION := 0.08

var fighter_data: Dictionary = {}
var dash_config: Dictionary = {}
var input_prefix := ""
var player_slot := 0
var display_name := "斗士"
var spawn_point := Vector2.ZERO
var facing := 1
var stocks := 3
var damage_percent := 0.0
var training_mode := false
var match_active := true

var state := State.IDLE
var current_attack_name := ""
var current_attack: Dictionary = {}
var attack_elapsed := 0.0
var attack_connected_targets := {}
var projectile_shots_fired := 0
var attack_buffer_slot := ""
var attack_buffer_timer := 0.0
var hitstun_timer := 0.0
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var invulnerable_timer := 0.0
var land_timer := 0.0
var air_jumps_left := 1
var air_dashes_left := 1
var is_gliding := false

var dash_state_elapsed := 0.0
var dash_direction := 1
var dash_buffer_timer := 0.0
var dash_requested_direction := 0
var dash_lockout_timer := 0.0
var dash_landing_recovery_pending := false
var dash_started_in_air := false
var last_tap_direction := 0
var last_tap_timer := 0.0
var last_landed_hit_summary := "-"
var last_received_hit_summary := "-"
var hit_flash_timer := 0.0
var hit_flash_color := Color.WHITE

var body_primary_color := Color("f95738")
var body_accent_color := Color("faf0ca")

func _ready() -> void:
	add_to_group("fighters")
	collision_layer = 1
	collision_mask = 1
	floor_snap_length = 14.0
	_safe_create_collision()
	queue_redraw()

func configure(data: Dictionary, prefix: String, spawn: Vector2, slot: int, stock_count: int, is_training: bool) -> void:
	fighter_data = data.duplicate(true)
	dash_config = DashConfig.build(fighter_data.get("dash_config", {}))
	input_prefix = prefix
	spawn_point = spawn
	player_slot = slot
	stocks = stock_count
	training_mode = is_training
	display_name = fighter_data.get("name", "斗士")
	body_primary_color = fighter_data.get("primary_color", body_primary_color)
	body_accent_color = fighter_data.get("accent_color", body_accent_color)
	respawn(spawn_point, 0.9)

func prepare_for_new_match(stock_count: int) -> void:
	stocks = stock_count
	damage_percent = 0.0
	match_active = true
	_clear_attack_state()
	_clear_attack_buffer()
	_clear_debug_hit_summaries()
	_reset_dash_runtime()
	respawn(spawn_point, 0.9)

func respawn(at_position: Vector2, invulnerability_time: float = 1.0) -> void:
	global_position = at_position
	velocity = Vector2.ZERO
	damage_percent = 0.0
	invulnerable_timer = invulnerability_time
	air_jumps_left = int(fighter_data.get("max_air_jumps", 1))
	air_dashes_left = int(dash_config.get("maxAirDashes", 1))
	_clear_attack_state()
	_clear_attack_buffer()
	_clear_debug_hit_summaries()
	_reset_dash_runtime()
	jump_buffer_timer = 0.0
	hitstun_timer = 0.0
	land_timer = 0.0
	coyote_timer = float(fighter_data.get("coyote_time", 0.10))
	state = State.IDLE
	match_active = true
	visible = true
	queue_redraw()

func disable_for_ring_out() -> void:
	state = State.DEAD
	match_active = false
	visible = false
	velocity = Vector2.ZERO
	_clear_attack_state()
	_clear_attack_buffer()
	_clear_debug_hit_summaries()
	_reset_dash_runtime()
	queue_redraw()

func set_match_active(value: bool) -> void:
	match_active = value
	if not match_active and state != State.DEAD:
		velocity = Vector2.ZERO

func is_out_of_play() -> bool:
	return state == State.DEAD

func is_invulnerable() -> bool:
	return state == State.DEAD or invulnerable_timer > 0.0 or _has_dash_invulnerability()

func get_hurtbox_rect() -> Rect2:
	var hurtbox_size: Vector2 = BODY_SIZE
	if _is_dash_state(state):
		hurtbox_size = Vector2(
			BODY_SIZE.x * float(dash_config.get("hurtboxScaleX", 1.0)),
			BODY_SIZE.y * float(dash_config.get("hurtboxScaleY", 1.0))
		)
	return Rect2(global_position - hurtbox_size * 0.5, hurtbox_size)

func receive_hit(payload: Dictionary, attacker) -> void:
	if state == State.DEAD:
		return
	if is_invulnerable():
		return

	if _is_dash_state(state):
		_interrupt_dash("hit")

	damage_percent += float(payload.get("damage", 0.0))
	var direction: float = sign(global_position.x - attacker.global_position.x)
	if direction == 0.0:
		direction = float(attacker.facing)

	var magnitude: float = (
		float(payload.get("base_knockback", 520.0)) +
		damage_percent * float(payload.get("knockback_growth", 6.0))
	) / maxf(float(fighter_data.get("weight", 1.0)), 0.7)
	var launch_angle: float = deg_to_rad(float(payload.get("launch_angle", 40.0)))
	velocity = Vector2(cos(launch_angle) * magnitude * direction, -sin(launch_angle) * magnitude)
	hitstun_timer = float(payload.get("hitstun", 0.18)) + damage_percent * 0.0022
	_apply_hit_flash(payload, attacker)
	_record_received_hit(payload, attacker)
	state = State.HURT
	_clear_attack_state()
	_clear_attack_buffer()
	queue_redraw()

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	var was_on_floor: bool = is_on_floor()
	_tick_timers(delta)
	_capture_player_input()
	is_gliding = _can_glide()

	if match_active:
		_try_start_dash_from_buffer()
		_try_consume_jump()
		_try_start_buffered_attack()

	var horizontal_input: float = _get_horizontal_input()

	if state == State.HURT:
		_process_hitstun(delta)
	elif not current_attack.is_empty():
		_process_attack_state(horizontal_input, delta)
	elif _is_dash_state(state):
		_process_dash_state(horizontal_input, delta)
	else:
		_process_neutral_movement(horizontal_input, delta)

	_apply_gravity(delta)
	move_and_slide()
	_post_move_state_update(was_on_floor, horizontal_input)
	_resolve_melee_hits()
	_update_facing(horizontal_input)
	queue_redraw()

func _tick_timers(delta: float) -> void:
	if jump_buffer_timer > 0.0:
		jump_buffer_timer = maxf(jump_buffer_timer - delta, 0.0)

	if attack_buffer_timer > 0.0:
		attack_buffer_timer = maxf(attack_buffer_timer - delta, 0.0)
		if attack_buffer_timer == 0.0:
			attack_buffer_slot = ""

	if dash_buffer_timer > 0.0:
		dash_buffer_timer = maxf(dash_buffer_timer - delta, 0.0)
		if dash_buffer_timer == 0.0:
			dash_requested_direction = 0

	if invulnerable_timer > 0.0:
		invulnerable_timer = maxf(invulnerable_timer - delta, 0.0)

	if hit_flash_timer > 0.0:
		hit_flash_timer = maxf(hit_flash_timer - delta, 0.0)

	if hitstun_timer > 0.0:
		hitstun_timer = maxf(hitstun_timer - delta, 0.0)
		if hitstun_timer == 0.0 and state == State.HURT:
			_sync_locomotion_state(_get_horizontal_input())

	if coyote_timer > 0.0 and not is_on_floor():
		coyote_timer = maxf(coyote_timer - delta, 0.0)

	if dash_lockout_timer > 0.0:
		dash_lockout_timer = maxf(dash_lockout_timer - delta, 0.0)

	if land_timer > 0.0:
		land_timer = maxf(land_timer - delta, 0.0)

	if last_tap_timer > 0.0:
		last_tap_timer = maxf(last_tap_timer - delta, 0.0)
		if last_tap_timer == 0.0:
			last_tap_direction = 0

func _capture_player_input() -> void:
	if not match_active:
		return

	if bool(dash_config.get("allowDoubleTap", false)):
		_capture_double_tap_input()

	if bool(dash_config.get("useDedicatedButton", true)) and Input.is_action_just_pressed("%s_dash" % input_prefix):
		_buffer_dash(_resolve_requested_dash_direction())

	if Input.is_action_just_pressed("%s_jump" % input_prefix):
		jump_buffer_timer = float(fighter_data.get("jump_buffer", 0.12))

	if Input.is_action_just_released("%s_jump" % input_prefix) and velocity.y < 0.0:
		velocity.y *= float(TuningHub.FIGHTER_RUNTIME["jump_release_velocity_ratio"])

	if Input.is_action_just_pressed("%s_light" % input_prefix):
		_queue_or_start_attack_slot(_resolve_light_attack_slot())

	if Input.is_action_just_pressed("%s_heavy" % input_prefix):
		_queue_or_start_attack_slot(_resolve_heavy_attack_slot())

	if Input.is_action_just_pressed("%s_special" % input_prefix):
		_queue_or_start_attack_slot(_resolve_special_attack_slot())

func _capture_double_tap_input() -> void:
	if Input.is_action_just_pressed("%s_left" % input_prefix):
		_register_direction_tap(-1)
	if Input.is_action_just_pressed("%s_right" % input_prefix):
		_register_direction_tap(1)

func _register_direction_tap(direction: int) -> void:
	var max_gap_frames: int = int(dash_config.get("doubleTapMaxGapFrames", 8))
	if last_tap_direction == direction and last_tap_timer > 0.0:
		_buffer_dash(direction)
		last_tap_direction = 0
		last_tap_timer = 0.0
		return

	last_tap_direction = direction
	last_tap_timer = _frames_to_seconds(max_gap_frames)

func _buffer_dash(direction: int) -> void:
	if not bool(dash_config.get("enabled", true)):
		return
	dash_requested_direction = direction if direction != 0 else facing
	dash_buffer_timer = _frames_to_seconds(int(dash_config.get("inputBufferFrames", 6)))

func _try_start_dash_from_buffer() -> void:
	if dash_buffer_timer <= 0.0:
		return
	if not _can_start_dash():
		return

	var requested_direction: int = dash_requested_direction if dash_requested_direction != 0 else facing
	dash_buffer_timer = 0.0
	dash_requested_direction = 0
	_enter_dash_startup(requested_direction)

func _can_start_dash() -> bool:
	if not match_active:
		return false
	if not bool(dash_config.get("enabled", true)):
		return false
	if dash_lockout_timer > 0.0:
		return false
	if not current_attack.is_empty():
		return false
	if state == State.DEAD or state == State.HURT:
		return false

	if is_on_floor():
		return state == State.IDLE or state == State.RUN or state == State.LAND

	if not bool(dash_config.get("allowAirDash", true)):
		return false
	if air_dashes_left <= 0:
		return false

	return state == State.JUMP or state == State.FALL

func _queue_or_start_attack_slot(attack_slot: String) -> void:
	if attack_slot == "":
		return

	if _try_dash_attack_cancel(attack_slot):
		return

	if _can_start_attack():
		_start_attack(attack_slot)
	else:
		attack_buffer_slot = attack_slot
		attack_buffer_timer = float(TuningHub.FIGHTER_RUNTIME["attack_buffer_seconds"])

func _try_start_buffered_attack() -> void:
	if attack_buffer_slot == "":
		return
	if attack_buffer_timer <= 0.0:
		return

	if _try_dash_attack_cancel(attack_buffer_slot):
		_clear_attack_buffer()
		return

	if not _can_start_attack():
		return

	var queued_attack: String = attack_buffer_slot
	_clear_attack_buffer()
	_start_attack(queued_attack)

func _can_start_attack() -> bool:
	return match_active and state != State.DEAD and state != State.HURT and current_attack.is_empty() and not _is_dash_state(state)

func _start_attack(attack_name: String, inherited_velocity_x: float = NAN) -> void:
	if not fighter_data.has("attacks"):
		return
	if not fighter_data["attacks"].has(attack_name):
		return

	current_attack_name = attack_name
	current_attack = fighter_data["attacks"][attack_name].duplicate(true)
	current_attack["slot_id"] = attack_name
	attack_elapsed = 0.0
	attack_connected_targets.clear()
	projectile_shots_fired = 0
	state = State.ATTACK
	var lunge: float = float(current_attack.get("lunge", 0.0)) * facing
	if is_nan(inherited_velocity_x):
		velocity.x += lunge
	else:
		velocity.x = inherited_velocity_x + lunge

func _try_dash_attack_cancel(attack_slot: String) -> bool:
	if not _is_dash_state(state):
		return false
	if not bool(dash_config.get("allowAttackCancel", true)):
		return false
	if _is_special_attack_slot(attack_slot):
		return false
	if not _is_dash_window_open(
		int(dash_config.get("attackCancelStartFrame", 6)),
		int(dash_config.get("attackCancelEndFrame", 14))
	):
		return false

	var attacks: Dictionary = fighter_data.get("attacks", {})
	if not attacks.has("dash_attack"):
		return false

	var inherited_velocity_x: float = velocity.x * float(dash_config.get("dashAttackPreserveSpeedRatio", 0.35))
	_interrupt_dash("attack_cancel")
	_start_attack("dash_attack", inherited_velocity_x)
	_emit_dash_event("dash_cancel_attack")
	return true

func _resolve_light_attack_slot() -> String:
	if is_on_floor():
		return _resolve_first_available_attack_slot([
			"up_ground" if _has_up_attack_intent() else "",
			"down_ground" if _has_down_attack_intent() else "",
			"light_ground",
			"heavy_ground",
		])

	return _resolve_first_available_attack_slot([
		"forward_air" if _has_side_attack_intent() else "",
		"neutral_air",
		"forward_air",
	])

func _resolve_heavy_attack_slot() -> String:
	if is_on_floor():
		return _resolve_first_available_attack_slot([
			"heavy_ground",
			"up_ground" if _has_up_attack_intent() else "",
			"down_ground" if _has_down_attack_intent() else "",
			"light_ground",
		])

	return _resolve_first_available_attack_slot([
		"up_air" if _has_up_attack_intent() else "",
		"down_air" if _has_down_attack_intent() else "",
		"forward_air" if _has_side_attack_intent() else "",
		"neutral_air",
		"forward_air",
	])

func _resolve_special_attack_slot() -> String:
	return _resolve_first_available_attack_slot([
		"special_up" if _has_up_attack_intent() else "",
		"special_down" if _has_down_attack_intent() else "",
		"special_side" if _has_side_attack_intent() else "",
		"special_neutral",
		"heavy_ground",
	])

func _resolve_first_available_attack_slot(candidate_slots: Array[String]) -> String:
	var attacks: Dictionary = fighter_data.get("attacks", {})
	for slot_name in candidate_slots:
		if slot_name != "" and attacks.has(slot_name):
			return slot_name
	return ""

func _has_up_attack_intent() -> bool:
	return Input.is_action_pressed("%s_jump" % input_prefix)

func _has_down_attack_intent() -> bool:
	return Input.is_action_pressed("%s_down" % input_prefix)

func _has_side_attack_intent() -> bool:
	return absf(_get_horizontal_input()) > 0.35

func _is_special_attack_slot(attack_slot: String) -> bool:
	return attack_slot.begins_with("special_")

func _process_neutral_movement(horizontal_input: float, delta: float) -> void:
	var control_scale: float = 0.75 if state == State.LAND and land_timer > 0.0 else 1.0
	if is_gliding and not is_on_floor():
		control_scale = float(fighter_data.get("glide_horizontal_control", 1.0))
	_apply_horizontal_movement(horizontal_input, delta, control_scale)

func _process_attack_state(horizontal_input: float, delta: float) -> void:
	attack_elapsed += delta
	_apply_horizontal_movement(horizontal_input, delta, float(current_attack.get("movement_scale", 0.35)))

	if current_attack.get("type", "melee") == "projectile":
		_emit_projectile_shots_if_ready()

	if attack_elapsed >= _get_attack_total_time(current_attack):
		_clear_attack_state()
		if state != State.HURT:
			_sync_locomotion_state(horizontal_input)

func _emit_projectile_shots_if_ready() -> void:
	var startup: float = float(current_attack.get("startup", 0.0))
	var shot_count: int = max(int(current_attack.get("projectile_shot_count", 1)), 1)
	var burst_interval: float = maxf(float(current_attack.get("projectile_burst_interval", 0.0)), 0.0)

	while projectile_shots_fired < shot_count:
		var trigger_time: float = startup + burst_interval * float(projectile_shots_fired)
		if attack_elapsed < trigger_time:
			return

		var projectile_data: Dictionary = current_attack.duplicate(true)
		projectile_data["projectile_shot_index"] = projectile_shots_fired
		projectile_data["projectile_shot_count"] = shot_count
		projectile_requested.emit(self, projectile_data)
		projectile_shots_fired += 1

func _process_dash_state(horizontal_input: float, delta: float) -> void:
	dash_state_elapsed += delta
	var dash_speed: float = float(dash_config.get("dashSpeed", 720.0))
	if dash_started_in_air:
		dash_speed *= float(dash_config.get("airDashSpeedMultiplier", 1.0))
	var dash_acceleration: float = float(dash_config.get("dashAcceleration", 4800.0))
	var dash_brake: float = float(dash_config.get("dashBrake", 5400.0))
	var dash_velocity_x: float = float(dash_direction) * dash_speed

	match state:
		State.DASH_STARTUP:
			velocity.x = move_toward(velocity.x, dash_velocity_x * 0.55, dash_acceleration * delta)
			if dash_state_elapsed >= _frames_to_seconds(int(dash_config.get("startupFrames", 4))):
				_enter_dash_travel()
		State.DASH_TRAVEL:
			velocity.x = move_toward(velocity.x, dash_velocity_x, dash_acceleration * delta)
			if dash_state_elapsed >= _frames_to_seconds(int(dash_config.get("travelFrames", 10))):
				_enter_dash_recovery()
		State.DASH_RECOVERY:
			var run_speed: float = float(fighter_data.get("move_speed", 440.0))
			var recovery_target_speed: float = horizontal_input * run_speed if absf(horizontal_input) > 0.01 else 0.0
			velocity.x = move_toward(velocity.x, recovery_target_speed, dash_brake * delta)
			if dash_state_elapsed >= _frames_to_seconds(int(dash_config.get("recoveryFrames", 8))):
				_finish_dash(horizontal_input)

func _process_hitstun(delta: float) -> void:
	var drag: float = (
		float(fighter_data.get("ground_friction", 3200.0))
		if is_on_floor()
		else AIR_DRAG * float(TuningHub.FIGHTER_RUNTIME["hurt_air_drag_scale"])
	)
	velocity.x = move_toward(velocity.x, 0.0, drag * delta)

func _apply_horizontal_movement(horizontal_input: float, delta: float, control_scale: float) -> void:
	var on_floor: bool = is_on_floor()
	if absf(horizontal_input) > 0.01:
		var max_speed: float = float(fighter_data.get("move_speed", 440.0)) if on_floor else float(fighter_data.get("air_speed", 390.0))
		var target_speed: float = horizontal_input * max_speed * control_scale
		var accel: float = float(fighter_data.get("ground_accel", 3000.0)) if on_floor else float(fighter_data.get("air_accel", 2200.0))
		velocity.x = move_toward(velocity.x, target_speed, accel * delta)
	else:
		var friction: float = float(fighter_data.get("ground_friction", 3400.0)) if on_floor else AIR_DRAG
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

func _apply_gravity(delta: float) -> void:
	if is_on_floor() and velocity.y >= 0.0:
		velocity.y = 0.0
		return

	var max_fall_speed: float = float(fighter_data.get("max_fall_speed", 1280.0))
	if Input.is_action_pressed("%s_down" % input_prefix) and velocity.y > 0.0:
		max_fall_speed = float(fighter_data.get("fast_fall_speed", 1680.0))

	var gravity_scale := 1.0
	if dash_started_in_air and _is_dash_state(state):
		gravity_scale = float(dash_config.get("airDashGravityScale", 0.12))
	elif is_gliding:
		gravity_scale = 0.18
		max_fall_speed = minf(max_fall_speed, float(fighter_data.get("glide_fall_speed", 220.0)))

	velocity.y = minf(velocity.y + float(fighter_data.get("gravity", 2500.0)) * gravity_scale * delta, max_fall_speed)

func _try_consume_jump() -> void:
	if jump_buffer_timer <= 0.0:
		return
	if state == State.DEAD:
		return
	if current_attack_name != "" and attack_elapsed < float(current_attack.get("startup", 0.0)):
		return

	if _try_dash_jump_cancel():
		return

	if is_on_floor() or coyote_timer > 0.0:
		_start_ground_jump()
		return

	if air_jumps_left > 0:
		_start_air_jump()

func _try_dash_jump_cancel() -> bool:
	if not _is_dash_state(state):
		return false
	if not bool(dash_config.get("allowJumpCancel", true)):
		return false
	if not _is_dash_window_open(
		int(dash_config.get("jumpCancelStartFrame", 5)),
		int(dash_config.get("jumpCancelEndFrame", 12))
	):
		return false

	if dash_started_in_air and air_jumps_left <= 0:
		return false

	var carried_velocity_x: float = velocity.x * float(dash_config.get("airCarryRatioOnExit", 0.70))
	var was_air_dash: bool = dash_started_in_air
	_interrupt_dash("jump_cancel")
	if was_air_dash:
		_start_air_jump(carried_velocity_x)
	else:
		_start_ground_jump(carried_velocity_x)
	_emit_dash_event("dash_cancel_jump")
	return true

func _start_ground_jump(carried_velocity_x: float = NAN) -> void:
	jump_buffer_timer = 0.0
	coyote_timer = 0.0
	air_jumps_left = int(fighter_data.get("max_air_jumps", 1))
	velocity.y = float(fighter_data.get("jump_velocity", -920.0))
	if not is_nan(carried_velocity_x):
		velocity.x = carried_velocity_x
	state = State.JUMP

func _start_air_jump(carried_velocity_x: float = NAN) -> void:
	jump_buffer_timer = 0.0
	coyote_timer = 0.0
	air_jumps_left -= 1
	velocity.y = float(fighter_data.get("double_jump_velocity", fighter_data.get("jump_velocity", -920.0)))
	if not is_nan(carried_velocity_x):
		velocity.x = carried_velocity_x
	state = State.JUMP

func _post_move_state_update(was_on_floor: bool, horizontal_input: float) -> void:
	if is_on_floor():
		air_jumps_left = int(fighter_data.get("max_air_jumps", 1))
		air_dashes_left = int(dash_config.get("maxAirDashes", 1))
		is_gliding = false
		coyote_timer = float(fighter_data.get("coyote_time", 0.10))
		if not was_on_floor:
			if dash_landing_recovery_pending:
				dash_landing_recovery_pending = false
				land_timer = maxf(land_timer, _frames_to_seconds(int(dash_config.get("landingRecoveryFrames", 4))))
				state = State.LAND
			elif current_attack.is_empty() and state != State.HURT and not _is_dash_state(state):
				land_timer = maxf(land_timer, LAND_STATE_DURATION)
				state = State.LAND
	elif was_on_floor and velocity.y >= 0.0:
		coyote_timer = float(fighter_data.get("coyote_time", 0.10))

	if _is_dash_state(state) and not is_on_floor() and not dash_started_in_air:
		_exit_dash_to_fall()

	if state == State.HURT:
		if hitstun_timer <= 0.0:
			_sync_locomotion_state(horizontal_input)
		return

	if not current_attack.is_empty() or _is_dash_state(state) or state == State.DEAD:
		return

	_sync_locomotion_state(horizontal_input)

func _sync_locomotion_state(horizontal_input: float) -> void:
	if state == State.DEAD or state == State.HURT or not current_attack.is_empty() or _is_dash_state(state):
		return

	if is_on_floor():
		if land_timer > 0.0:
			state = State.LAND
		elif absf(horizontal_input) > 0.01 and absf(velocity.x) > 24.0:
			state = State.RUN
		else:
			state = State.IDLE
	else:
		state = State.JUMP if velocity.y < 0.0 else State.FALL

func _can_glide() -> bool:
	if not bool(fighter_data.get("can_glide", false)):
		return false
	if is_on_floor():
		return false
	if velocity.y <= 0.0:
		return false
	if _is_dash_state(state) or state == State.HURT or state == State.DEAD:
		return false
	if not current_attack.is_empty():
		return false
	return Input.is_action_pressed("%s_jump" % input_prefix)

func _resolve_melee_hits() -> void:
	if current_attack.is_empty():
		return
	if current_attack.get("type", "melee") != "melee":
		return
	if attack_elapsed < float(current_attack.get("startup", 0.0)):
		return
	if attack_elapsed > float(current_attack.get("startup", 0.0)) + float(current_attack.get("active", 0.0)):
		return

	var attack_rect: Rect2 = get_attack_rect()
	for node in get_tree().get_nodes_in_group("fighters"):
		if node == self:
			continue
		if node.is_out_of_play():
			continue
		if node.is_invulnerable():
			continue
		var target_id: int = node.get_instance_id()
		if attack_connected_targets.has(target_id):
			continue
		if attack_rect.intersects(node.get_hurtbox_rect()):
			var hit_payload: Dictionary = _build_hit_payload(current_attack)
			if node.has_method("try_guard_hit") and node.try_guard_hit(hit_payload, self):
				attack_connected_targets[target_id] = true
				continue
			node.receive_hit(hit_payload, self)
			register_attack_landed(node, hit_payload)
			attack_connected_targets[target_id] = true

func _build_hit_payload(attack_data: Dictionary) -> Dictionary:
	return {
		"attack_slot": current_attack_name,
		"attack_name": attack_data.get("name", current_attack_name),
		"damage": attack_data.get("damage", 7.0),
		"base_knockback": attack_data.get("base_knockback", 480.0),
		"knockback_growth": attack_data.get("knockback_growth", 5.5),
		"launch_angle": attack_data.get("launch_angle", 32.0),
		"hitstun": attack_data.get("hitstun", 0.16),
	}

func try_guard_hit(payload: Dictionary, attacker, hit_source = null) -> bool:
	if not _is_guard_window_active():
		return false

	var guard_profile: Dictionary = current_attack.get("guard_profile", {})
	var push_direction: float = 0.0
	if attacker != null:
		push_direction = sign(global_position.x - attacker.global_position.x)
	if push_direction == 0.0:
		push_direction = -float(facing)

	velocity.x = push_direction * float(guard_profile.get("pushback_speed", 180.0))
	invulnerable_timer = maxf(invulnerable_timer, float(guard_profile.get("post_guard_invulnerability", 0.08)))

	if hit_source != null and hit_source.has_method("on_blocked_by"):
		hit_source.on_blocked_by(self, guard_profile)

	_record_guard_success(payload, attacker, hit_source != null)
	return true

func _is_guard_window_active() -> bool:
	if current_attack.is_empty():
		return false
	if not current_attack.has("guard_profile"):
		return false

	var guard_profile: Dictionary = current_attack.get("guard_profile", {})
	if guard_profile.is_empty():
		return false

	var start_time: float = float(guard_profile.get("window_start", 0.0))
	var end_time: float = float(guard_profile.get("window_end", _get_attack_total_time(current_attack)))
	return attack_elapsed >= start_time and attack_elapsed <= end_time

func get_attack_rect() -> Rect2:
	if current_attack.is_empty():
		return Rect2()

	var size: Vector2 = current_attack.get("hitbox_size", Vector2(76.0, 34.0))
	var offset: Vector2 = current_attack.get("hitbox_offset", Vector2(60.0, 0.0))
	offset.x *= facing
	return Rect2(global_position + offset - size * 0.5, size)

func _get_attack_total_time(attack_data: Dictionary) -> float:
	return float(attack_data.get("startup", 0.0)) + float(attack_data.get("active", 0.0)) + float(attack_data.get("recovery", 0.0))

func _get_horizontal_input() -> float:
	return Input.get_action_strength("%s_right" % input_prefix) - Input.get_action_strength("%s_left" % input_prefix)

func _resolve_requested_dash_direction() -> int:
	var horizontal_input: float = _get_horizontal_input()
	if absf(horizontal_input) > 0.01:
		return 1 if horizontal_input > 0.0 else -1
	return facing

func _update_facing(horizontal_input: float) -> void:
	if absf(horizontal_input) < 0.01:
		return
	if state == State.HURT or state == State.DEAD:
		return
	if _is_dash_direction_locked():
		return
	facing = 1 if horizontal_input > 0.0 else -1

func _enter_dash_startup(direction: int) -> void:
	dash_direction = 1 if direction >= 0 else -1
	facing = dash_direction
	dash_state_elapsed = 0.0
	dash_landing_recovery_pending = false
	dash_started_in_air = not is_on_floor()
	if dash_started_in_air:
		air_dashes_left = max(air_dashes_left - 1, 0)
	state = State.DASH_STARTUP
	_emit_dash_event("dash_start")

func _enter_dash_travel() -> void:
	dash_state_elapsed = 0.0
	state = State.DASH_TRAVEL
	_emit_dash_event("dash_travel_enter")

func _enter_dash_recovery() -> void:
	dash_state_elapsed = 0.0
	state = State.DASH_RECOVERY

func _finish_dash(horizontal_input: float) -> void:
	_apply_dash_lockout()
	dash_state_elapsed = 0.0
	dash_started_in_air = false
	state = State.IDLE
	_emit_dash_event("dash_end")
	_sync_locomotion_state(horizontal_input)

func _exit_dash_to_fall() -> void:
	if not bool(dash_config.get("runOffLedge", true)):
		_enter_dash_recovery()
		return

	_apply_dash_lockout()
	dash_landing_recovery_pending = int(dash_config.get("landingRecoveryFrames", 4)) > 0
	velocity.x *= float(dash_config.get("airCarryRatioOnExit", 0.70))
	dash_state_elapsed = 0.0
	dash_started_in_air = false
	state = State.FALL
	_emit_dash_event("dash_end")

func _interrupt_dash(reason: String) -> void:
	_apply_dash_lockout()
	dash_state_elapsed = 0.0
	dash_landing_recovery_pending = false
	dash_started_in_air = false
	if reason == "hit":
		_emit_dash_event("dash_interrupted", {"reason": reason})

func _apply_dash_lockout() -> void:
	dash_lockout_timer = _frames_to_seconds(int(dash_config.get("reDashLockoutFrames", 6)))
	dash_buffer_timer = 0.0
	dash_requested_direction = 0

func _has_dash_invulnerability() -> bool:
	if not _is_dash_state(state):
		return false
	if not bool(dash_config.get("hasInvulnerability", false)):
		return false

	var start_frame: int = int(dash_config.get("invulnStartFrame", -1))
	var end_frame: int = int(dash_config.get("invulnEndFrame", -1))
	if start_frame < 0 or end_frame < start_frame:
		return false

	var current_frame: int = _get_dash_frame()
	return current_frame >= start_frame and current_frame <= end_frame

func _is_dash_window_open(start_frame: int, end_frame: int) -> bool:
	var current_frame: int = _get_dash_frame()
	return current_frame >= start_frame and current_frame <= end_frame

func _get_dash_frame() -> int:
	return int(floor(dash_state_elapsed / FRAME_DURATION)) + 1

func _is_dash_direction_locked() -> bool:
	if not _is_dash_state(state):
		return false
	return dash_state_elapsed < _frames_to_seconds(int(dash_config.get("directionLockFrames", 6)))

func _is_dash_state(value: int) -> bool:
	return value == State.DASH_STARTUP or value == State.DASH_TRAVEL or value == State.DASH_RECOVERY

func _emit_dash_event(event_name: String, details: Dictionary = {}) -> void:
	var payload: Dictionary = {
		"state": state,
		"direction": dash_direction,
		"trait_id": dash_config.get("uniqueTraitId", "none"),
	}
	for key in details.keys():
		payload[key] = details[key]
	dash_event.emit(event_name, self, payload)

func _frames_to_seconds(frame_count: int) -> float:
	return maxf(float(frame_count), 0.0) * FRAME_DURATION

func get_debug_state_label() -> String:
	match state:
		State.IDLE:
			return "待机"
		State.RUN:
			return "奔跑"
		State.JUMP:
			return "跳跃"
		State.FALL:
			return "滑翔" if is_gliding else "下落"
		State.LAND:
			return "落地"
		State.ATTACK:
			return "攻击"
		State.HURT:
			return "受击"
		State.DASH_STARTUP:
			return "闪避前摇"
		State.DASH_TRAVEL:
			return "闪避移动"
		State.DASH_RECOVERY:
			return "闪避后摇"
		State.DEAD:
			return "离场"
	return "未知"

func get_current_attack_slot_label() -> String:
	if current_attack.is_empty():
		return "-"
	return String(current_attack.get("name", _get_attack_slot_display_name(current_attack_name)))

func _get_attack_slot_display_name(slot_name: String) -> String:
	var slot_labels := {
		"light_ground": "地面轻攻击",
		"heavy_ground": "地面重攻击",
		"up_ground": "上地面技",
		"down_ground": "下地面技",
		"dash_attack": "冲刺攻击",
		"neutral_air": "中立空中技",
		"forward_air": "前空中技",
		"up_air": "上空中技",
		"down_air": "下空中技",
		"special_neutral": "中立必杀",
		"special_side": "侧必杀",
		"special_up": "上必杀",
		"special_down": "下必杀",
	}
	return String(slot_labels.get(slot_name, slot_name))

func get_last_landed_hit_summary() -> String:
	return last_landed_hit_summary

func get_last_received_hit_summary() -> String:
	return last_received_hit_summary

func get_character_name_label() -> String:
	return String(fighter_data.get("character_name", display_name))

func get_weapon_name_label() -> String:
	return String(fighter_data.get("weapon_name", "武器"))

func get_loadout_label() -> String:
	return "%s / %s" % [get_character_name_label(), get_weapon_name_label()]

func get_debug_flags_label() -> String:
	var flags: Array[String] = []
	flags.append("地面" if is_on_floor() else "空中")
	if _is_dash_state(state):
		flags.append("闪避")
	if _is_guard_window_active():
		flags.append("防御")
	if is_gliding:
		flags.append("滑翔")
	if state == State.HURT:
		flags.append("受击")
	if is_invulnerable():
		flags.append("无敌")
	return " ".join(flags)

func get_debug_velocity_label() -> String:
	return "横速 %.0f 纵速 %.0f" % [velocity.x, velocity.y]

func get_debug_timer_label() -> String:
	return "硬直 %.2f 无敌 %.2f 落地 %.2f" % [hitstun_timer, invulnerable_timer, land_timer]

func get_air_dash_count_label() -> String:
	return "%d/%d" % [air_dashes_left, int(dash_config.get("maxAirDashes", 1))]

func get_air_jump_count_label() -> String:
	return "%d/%d" % [air_jumps_left, int(fighter_data.get("max_air_jumps", 1))]

func register_attack_landed(target, payload: Dictionary) -> void:
	var attack_slot: String = String(payload.get("attack_name", payload.get("attack_slot", "命中")))
	var target_slot: int = int(target.player_slot) if target != null else -1
	var target_label := "目标" if target_slot < 0 else "玩家%d" % target_slot
	last_landed_hit_summary = "%s -> %s +%.1f @%.0f" % [
		attack_slot,
		target_label,
		float(payload.get("damage", 0.0)),
		float(payload.get("launch_angle", 0.0)),
	]
	_emit_combat_feedback("hit_landed", _build_feedback_payload(payload, target_slot, true))

func _clear_attack_state() -> void:
	current_attack = {}
	current_attack_name = ""
	attack_elapsed = 0.0
	attack_connected_targets.clear()
	projectile_shots_fired = 0

func _clear_debug_hit_summaries() -> void:
	last_landed_hit_summary = "-"
	last_received_hit_summary = "-"

func _record_received_hit(payload: Dictionary, attacker) -> void:
	var attack_slot: String = String(payload.get("attack_name", payload.get("attack_slot", "受击")))
	var attacker_slot: int = int(attacker.player_slot) if attacker != null else -1
	var attacker_label := "来源" if attacker_slot < 0 else "玩家%d" % attacker_slot
	last_received_hit_summary = "%s <- %s +%.1f @%.0f" % [
		attack_slot,
		attacker_label,
		float(payload.get("damage", 0.0)),
		float(payload.get("launch_angle", 0.0)),
	]
	_emit_combat_feedback("hit_received", _build_feedback_payload(payload, attacker_slot, false))

func _record_guard_success(payload: Dictionary, attacker, was_projectile: bool) -> void:
	var attack_slot: String = String(payload.get("attack_name", payload.get("attack_slot", "格挡")))
	var attacker_slot: int = int(attacker.player_slot) if attacker != null else -1
	var attacker_label := "来源" if attacker_slot < 0 else "玩家%d" % attacker_slot
	var action_label := "反制弹道" if was_projectile else "格挡近战"
	last_received_hit_summary = "%s <- %s %s" % [attack_slot, attacker_label, action_label]
	_emit_combat_feedback("guard_success", {
		"attack_slot": String(current_attack_name),
		"attack_name": String(current_attack.get("name", current_attack_name)),
		"blocked_attack_name": attack_slot,
		"blocked_from_slot": attacker_slot,
		"owner_slot": player_slot,
		"is_projectile": was_projectile,
	})

func _build_feedback_payload(payload: Dictionary, other_slot: int, is_landed: bool) -> Dictionary:
	return {
		"attack_slot": String(payload.get("attack_slot", payload.get("attack_name", "命中"))),
		"attack_name": String(payload.get("attack_name", payload.get("attack_slot", "命中"))),
		"damage": float(payload.get("damage", 0.0)),
		"launch_angle": float(payload.get("launch_angle", 0.0)),
		"is_projectile": bool(payload.get("is_projectile", false)),
		"hit_strength": _classify_hit_strength(payload),
		"other_slot": other_slot,
		"owner_slot": player_slot,
		"is_landed": is_landed,
	}

func _classify_hit_strength(payload: Dictionary) -> String:
	var damage: float = float(payload.get("damage", 0.0))
	var base_knockback: float = float(payload.get("base_knockback", 0.0))
	if damage >= 10.0 or base_knockback >= 560.0:
		return "heavy"
	if damage >= 8.0 or base_knockback >= 500.0:
		return "medium"
	return "light"

func _apply_hit_flash(payload: Dictionary, attacker) -> void:
	var strength: String = _classify_hit_strength(payload)
	hit_flash_timer = float(
		TuningHub.FIGHTER_RUNTIME["heavy_hit_flash_seconds"]
		if strength == "heavy"
		else TuningHub.FIGHTER_RUNTIME["default_hit_flash_seconds"]
	)
	if attacker != null:
		hit_flash_color = attacker.body_accent_color
	else:
		hit_flash_color = (
			TuningHub.FIGHTER_RUNTIME["fallback_heavy_hit_flash_color"]
			if strength == "heavy"
			else TuningHub.FIGHTER_RUNTIME["fallback_default_hit_flash_color"]
		)

func _emit_combat_feedback(event_name: String, details: Dictionary) -> void:
	combat_feedback.emit(event_name, self, details)

func _clear_attack_buffer() -> void:
	attack_buffer_slot = ""
	attack_buffer_timer = 0.0

func _reset_dash_runtime() -> void:
	dash_state_elapsed = 0.0
	dash_direction = facing
	dash_buffer_timer = 0.0
	dash_requested_direction = 0
	dash_lockout_timer = 0.0
	dash_landing_recovery_pending = false
	dash_started_in_air = false
	last_tap_direction = 0
	last_tap_timer = 0.0

func _safe_create_collision() -> void:
	if has_node("BodyCollision"):
		return

	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = BODY_SIZE
	var collision: CollisionShape2D = CollisionShape2D.new()
	collision.name = "BodyCollision"
	collision.shape = shape
	add_child(collision)

func _draw() -> void:
	if state == State.DEAD:
		return

	var body_rect: Rect2 = Rect2(get_hurtbox_rect().position - global_position, get_hurtbox_rect().size)
	var fill: Color = body_primary_color
	if invulnerable_timer > 0.0 and int(Time.get_ticks_msec() / 120.0) % 2 == 0:
		fill = fill.lerp(Color.WHITE, 0.45)
	elif hit_flash_timer > 0.0:
		fill = fill.lerp(
			hit_flash_color,
			minf(
				hit_flash_timer * float(TuningHub.FIGHTER_RUNTIME["hit_flash_blend_speed"]),
				float(TuningHub.FIGHTER_RUNTIME["hit_flash_max_blend"])
			)
		)
	elif _is_dash_state(state):
		fill = fill.lerp(body_accent_color, 0.30)
	draw_rect(body_rect, fill, true)

	var chest_rect: Rect2 = Rect2(Vector2(-18.0, -10.0), Vector2(36.0, 28.0))
	draw_rect(chest_rect, body_accent_color, true)

	var visor_offset_x: float = 8.0 if facing > 0 else -26.0
	var visor_rect: Rect2 = Rect2(Vector2(visor_offset_x, -28.0), Vector2(18.0, 10.0))
	draw_rect(visor_rect, Color("13212d"), true)

	if not current_attack.is_empty() and current_attack.get("type", "melee") == "melee":
		var local_offset: Vector2 = current_attack.get("hitbox_offset", Vector2.ZERO)
		local_offset.x *= facing
		var attack_size: Vector2 = current_attack.get("hitbox_size", Vector2(70.0, 30.0))
		var local_rect: Rect2 = Rect2(local_offset - attack_size * 0.5, attack_size)
		var debug_color: Color = body_accent_color
		debug_color.a = 0.35 if attack_elapsed >= float(current_attack.get("startup", 0.0)) else 0.18
		draw_rect(local_rect, debug_color, true)
