extends CharacterBody2D
class_name Fighter

signal projectile_requested(attacker, attack_data)

enum State {
	IDLE,
	ATTACK,
	HURT,
	DEAD,
}

const BODY_SIZE := Vector2(54.0, 96.0)
const AIR_DRAG := 900.0

var fighter_data: Dictionary = {}
var input_prefix := ""
var player_slot := 0
var display_name := "Fighter"
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
var projectile_spawned := false
var attack_buffer_name := ""
var attack_buffer_timer := 0.0
var hitstun_timer := 0.0
var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var invulnerable_timer := 0.0
var air_jumps_left := 1

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
	input_prefix = prefix
	spawn_point = spawn
	player_slot = slot
	stocks = stock_count
	training_mode = is_training
	display_name = fighter_data.get("name", "Fighter")
	body_primary_color = fighter_data.get("primary_color", body_primary_color)
	body_accent_color = fighter_data.get("accent_color", body_accent_color)
	respawn(spawn_point, 0.9)

func prepare_for_new_match(stock_count: int) -> void:
	stocks = stock_count
	damage_percent = 0.0
	match_active = true
	current_attack.clear()
	current_attack_name = ""
	attack_buffer_name = ""
	attack_buffer_timer = 0.0
	projectile_spawned = false
	respawn(spawn_point, 0.9)

func respawn(at_position: Vector2, invulnerability_time: float = 1.0) -> void:
	global_position = at_position
	velocity = Vector2.ZERO
	damage_percent = 0.0
	invulnerable_timer = invulnerability_time
	air_jumps_left = fighter_data.get("max_air_jumps", 1)
	current_attack = {}
	current_attack_name = ""
	projectile_spawned = false
	attack_connected_targets.clear()
	attack_elapsed = 0.0
	attack_buffer_name = ""
	attack_buffer_timer = 0.0
	jump_buffer_timer = 0.0
	hitstun_timer = 0.0
	coyote_timer = fighter_data.get("coyote_time", 0.10)
	state = State.IDLE
	match_active = true
	visible = true
	queue_redraw()

func disable_for_ring_out() -> void:
	state = State.DEAD
	match_active = false
	visible = false
	velocity = Vector2.ZERO
	current_attack = {}
	current_attack_name = ""
	attack_buffer_name = ""
	attack_buffer_timer = 0.0
	projectile_spawned = false
	queue_redraw()

func set_match_active(value: bool) -> void:
	match_active = value
	if not match_active and state != State.DEAD:
		velocity = Vector2.ZERO

func is_out_of_play() -> bool:
	return state == State.DEAD

func is_invulnerable() -> bool:
	return state == State.DEAD or invulnerable_timer > 0.0

func get_hurtbox_rect() -> Rect2:
	return Rect2(global_position - BODY_SIZE * 0.5, BODY_SIZE)

func receive_hit(payload: Dictionary, attacker) -> void:
	if state == State.DEAD:
		return
	if invulnerable_timer > 0.0:
		return

	damage_percent += payload.get("damage", 0.0)
	var direction: float = sign(global_position.x - attacker.global_position.x)
	if direction == 0:
		direction = float(attacker.facing)

	var magnitude: float = (float(payload.get("base_knockback", 520.0)) + damage_percent * float(payload.get("knockback_growth", 6.0))) / maxf(float(fighter_data.get("weight", 1.0)), 0.7)
	var launch_angle: float = deg_to_rad(float(payload.get("launch_angle", 40.0)))
	velocity = Vector2(cos(launch_angle) * magnitude * direction, -sin(launch_angle) * magnitude)
	hitstun_timer = payload.get("hitstun", 0.18) + damage_percent * 0.0022
	state = State.HURT
	current_attack = {}
	current_attack_name = ""
	attack_buffer_name = ""
	attack_buffer_timer = 0.0
	projectile_spawned = false
	queue_redraw()

func _physics_process(delta: float) -> void:
	if state == State.DEAD:
		return

	var was_on_floor: bool = is_on_floor()
	_tick_timers(delta)
	_capture_player_input()

	if match_active:
		_try_consume_jump()
		_try_start_buffered_attack()

	var horizontal_input: float = _get_horizontal_input()

	if state == State.HURT:
		_process_hitstun(delta)
	elif current_attack.is_empty():
		_process_neutral_movement(horizontal_input, delta)
	else:
		_process_attack_state(horizontal_input, delta)

	_apply_gravity(delta)
	move_and_slide()
	_post_move_state_update(was_on_floor)
	_resolve_melee_hits()
	_update_facing(horizontal_input)
	queue_redraw()

func _tick_timers(delta: float) -> void:
	if jump_buffer_timer > 0.0:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

	if attack_buffer_timer > 0.0:
		attack_buffer_timer = max(attack_buffer_timer - delta, 0.0)
		if attack_buffer_timer == 0.0:
			attack_buffer_name = ""

	if invulnerable_timer > 0.0:
		invulnerable_timer = max(invulnerable_timer - delta, 0.0)

	if hitstun_timer > 0.0:
		hitstun_timer = max(hitstun_timer - delta, 0.0)
		if hitstun_timer == 0.0 and state == State.HURT:
			state = State.IDLE

	if coyote_timer > 0.0 and not is_on_floor():
		coyote_timer = max(coyote_timer - delta, 0.0)

func _capture_player_input() -> void:
	if not match_active:
		return

	if Input.is_action_just_pressed("%s_jump" % input_prefix):
		jump_buffer_timer = fighter_data.get("jump_buffer", 0.12)

	if Input.is_action_just_released("%s_jump" % input_prefix) and velocity.y < 0.0:
		velocity.y *= 0.55

	if Input.is_action_just_pressed("%s_light" % input_prefix):
		_queue_or_start_attack("light")

	if Input.is_action_just_pressed("%s_heavy" % input_prefix):
		_queue_or_start_attack("heavy")

func _queue_or_start_attack(attack_name: String) -> void:
	if _can_start_attack():
		_start_attack(attack_name)
	else:
		attack_buffer_name = attack_name
		attack_buffer_timer = 0.20

func _try_start_buffered_attack() -> void:
	if attack_buffer_name == "":
		return
	if attack_buffer_timer <= 0.0:
		return
	if not _can_start_attack():
		return

	var queued_attack: String = attack_buffer_name
	attack_buffer_name = ""
	attack_buffer_timer = 0.0
	_start_attack(queued_attack)

func _can_start_attack() -> bool:
	return match_active and state != State.DEAD and state != State.HURT and current_attack.is_empty()

func _start_attack(attack_name: String) -> void:
	if not fighter_data.has("attacks"):
		return
	if not fighter_data["attacks"].has(attack_name):
		return

	current_attack_name = attack_name
	current_attack = fighter_data["attacks"][attack_name].duplicate(true)
	attack_elapsed = 0.0
	attack_connected_targets.clear()
	projectile_spawned = false
	state = State.ATTACK
	velocity.x += current_attack.get("lunge", 0.0) * facing

func _process_neutral_movement(horizontal_input: float, delta: float) -> void:
	_apply_horizontal_movement(horizontal_input, delta, 1.0)

func _process_attack_state(horizontal_input: float, delta: float) -> void:
	attack_elapsed += delta
	_apply_horizontal_movement(horizontal_input, delta, current_attack.get("movement_scale", 0.35))

	if current_attack.get("type", "melee") == "projectile" and not projectile_spawned and attack_elapsed >= current_attack.get("startup", 0.0):
		projectile_spawned = true
		projectile_requested.emit(self, current_attack.duplicate(true))

	if attack_elapsed >= _get_attack_total_time(current_attack):
		current_attack = {}
		current_attack_name = ""
		attack_elapsed = 0.0
		projectile_spawned = false
		if state != State.HURT:
			state = State.IDLE

func _process_hitstun(delta: float) -> void:
	var drag: float = float(fighter_data.get("ground_friction", 3200.0)) if is_on_floor() else AIR_DRAG * 0.35
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

	velocity.y = min(velocity.y + fighter_data.get("gravity", 2500.0) * delta, max_fall_speed)

func _try_consume_jump() -> void:
	if jump_buffer_timer <= 0.0:
		return
	if state == State.DEAD:
		return
	if current_attack_name != "" and attack_elapsed < current_attack.get("startup", 0.0):
		return

	if is_on_floor() or coyote_timer > 0.0:
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		velocity.y = fighter_data.get("jump_velocity", -920.0)
		air_jumps_left = fighter_data.get("max_air_jumps", 1)
		state = State.IDLE
		return

	if air_jumps_left > 0:
		jump_buffer_timer = 0.0
		coyote_timer = 0.0
		air_jumps_left -= 1
		velocity.y = fighter_data.get("double_jump_velocity", fighter_data.get("jump_velocity", -920.0))
		state = State.IDLE

func _post_move_state_update(was_on_floor: bool) -> void:
	if is_on_floor():
		air_jumps_left = fighter_data.get("max_air_jumps", 1)
		coyote_timer = fighter_data.get("coyote_time", 0.10)
		if not was_on_floor and state == State.HURT and hitstun_timer == 0.0:
			state = State.IDLE
	elif was_on_floor and velocity.y >= 0.0:
		coyote_timer = fighter_data.get("coyote_time", 0.10)

func _resolve_melee_hits() -> void:
	if current_attack.is_empty():
		return
	if current_attack.get("type", "melee") != "melee":
		return
	if attack_elapsed < current_attack.get("startup", 0.0):
		return
	if attack_elapsed > current_attack.get("startup", 0.0) + current_attack.get("active", 0.0):
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
			node.receive_hit(_build_hit_payload(current_attack), self)
			attack_connected_targets[target_id] = true

func _build_hit_payload(attack_data: Dictionary) -> Dictionary:
	return {
		"damage": attack_data.get("damage", 7.0),
		"base_knockback": attack_data.get("base_knockback", 480.0),
		"knockback_growth": attack_data.get("knockback_growth", 5.5),
		"launch_angle": attack_data.get("launch_angle", 32.0),
		"hitstun": attack_data.get("hitstun", 0.16),
	}

func get_attack_rect() -> Rect2:
	if current_attack.is_empty():
		return Rect2()

	var size: Vector2 = current_attack.get("hitbox_size", Vector2(76.0, 34.0))
	var offset: Vector2 = current_attack.get("hitbox_offset", Vector2(60.0, 0.0))
	offset.x *= facing
	return Rect2(global_position + offset - size * 0.5, size)

func _get_attack_total_time(attack_data: Dictionary) -> float:
	return attack_data.get("startup", 0.0) + attack_data.get("active", 0.0) + attack_data.get("recovery", 0.0)

func _get_horizontal_input() -> float:
	return Input.get_action_strength("%s_right" % input_prefix) - Input.get_action_strength("%s_left" % input_prefix)

func _update_facing(horizontal_input: float) -> void:
	if absf(horizontal_input) < 0.01:
		return
	if state == State.HURT or state == State.DEAD:
		return
	facing = 1 if horizontal_input > 0.0 else -1

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

	var body_rect: Rect2 = Rect2(-BODY_SIZE * 0.5, BODY_SIZE)
	var fill: Color = body_primary_color
	if invulnerable_timer > 0.0 and int(Time.get_ticks_msec() / 120.0) % 2 == 0:
		fill = fill.lerp(Color.WHITE, 0.45)
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
		debug_color.a = 0.35 if attack_elapsed >= current_attack.get("startup", 0.0) else 0.18
		draw_rect(local_rect, debug_color, true)
