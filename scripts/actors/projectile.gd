extends Node2D
class_name Projectile

var source_fighter = null
var owner_slot: int = -1
var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 1.0
var age: float = 0.0
var payload: Dictionary = {}
var hitbox_size: Vector2 = Vector2(48.0, 24.0)
var fill_color: Color = Color.WHITE
var projectile_behavior := "linear"
var return_delay := 0.0
var return_speed := 900.0
var catch_radius := 42.0
var can_hit_on_return := false
var return_started := false

func configure(attacker, attack_data: Dictionary) -> void:
	source_fighter = attacker
	owner_slot = attacker.player_slot
	fill_color = attacker.body_accent_color
	payload = {
		"attack_slot": attack_data.get("slot_id", ""),
		"attack_name": attack_data.get("name", "投射物"),
		"is_projectile": true,
		"damage": attack_data.get("damage", 8.0),
		"base_knockback": attack_data.get("base_knockback", 540.0),
		"knockback_growth": attack_data.get("knockback_growth", 6.4),
		"launch_angle": attack_data.get("launch_angle", 16.0),
		"hitstun": attack_data.get("hitstun", 0.18),
		"can_be_reflected": attack_data.get("can_be_reflected", true),
	}
	hitbox_size = attack_data.get("hitbox_size", Vector2(48.0, 24.0))
	lifetime = attack_data.get("projectile_lifetime", 1.0)
	projectile_behavior = String(attack_data.get("projectile_behavior", "linear"))
	return_delay = float(attack_data.get("return_delay", lifetime * 0.5))
	return_speed = float(attack_data.get("return_speed", attack_data.get("projectile_speed", 900.0)))
	catch_radius = float(attack_data.get("catch_radius", 42.0))
	can_hit_on_return = bool(attack_data.get("can_hit_on_return", false))
	return_started = false
	age = 0.0

	var angle_radians: float = deg_to_rad(float(attack_data.get("projectile_angle", 0.0)))
	var direction := Vector2(cos(angle_radians), sin(angle_radians))
	direction.x *= attacker.facing
	velocity = direction.normalized() * float(attack_data.get("projectile_speed", 900.0))
	global_position = attacker.global_position + Vector2(
		attack_data.get("hitbox_offset", Vector2.ZERO).x * attacker.facing,
		attack_data.get("hitbox_offset", Vector2.ZERO).y
	)
	queue_redraw()

func _physics_process(delta: float) -> void:
	age += delta
	lifetime -= delta

	if lifetime <= 0.0:
		queue_free()
		return

	_update_motion(delta)
	if return_started and is_instance_valid(source_fighter):
		if global_position.distance_to(source_fighter.global_position) <= catch_radius:
			queue_free()
			return

	for node in get_tree().get_nodes_in_group("fighters"):
		if node == source_fighter:
			continue
		if node.player_slot == owner_slot:
			continue
		if node.is_out_of_play():
			continue
		if node.is_invulnerable():
			continue
		if return_started and not can_hit_on_return:
			continue
		if get_hitbox_rect().intersects(node.get_hurtbox_rect()):
			if node.has_method("try_guard_hit") and node.try_guard_hit(payload, source_fighter, self):
				if is_queued_for_deletion():
					return
				queue_redraw()
				return
			node.receive_hit(payload, source_fighter)
			if source_fighter and source_fighter.has_method("register_attack_landed"):
				source_fighter.register_attack_landed(node, payload)
			queue_free()
			return

	queue_redraw()

func get_hitbox_rect() -> Rect2:
	return Rect2(global_position - hitbox_size * 0.5, hitbox_size)

func on_blocked_by(guard_fighter, guard_profile: Dictionary) -> void:
	var response: String = String(guard_profile.get("projectile_response", "destroy"))
	if response == "reflect" and bool(payload.get("can_be_reflected", true)) and guard_fighter != null:
		source_fighter = guard_fighter
		owner_slot = guard_fighter.player_slot
		fill_color = guard_fighter.body_accent_color
		projectile_behavior = "linear"
		return_started = false

		var reflect_angle_radians: float = deg_to_rad(float(guard_profile.get("reflect_angle", 0.0)))
		var reflect_direction := Vector2(cos(reflect_angle_radians), sin(reflect_angle_radians))
		reflect_direction.x *= guard_fighter.facing
		velocity = reflect_direction.normalized() * maxf(return_speed, velocity.length())
		global_position = guard_fighter.global_position + Vector2(guard_fighter.facing * (hitbox_size.x * 0.6 + 24.0), -8.0)
		queue_redraw()
		return

	queue_free()

func _update_motion(delta: float) -> void:
	if projectile_behavior == "returning":
		if not return_started and age >= return_delay:
			return_started = true
		if return_started and is_instance_valid(source_fighter):
			var to_owner: Vector2 = source_fighter.global_position - global_position
			if to_owner.length() > 0.001:
				velocity = to_owner.normalized() * return_speed

	position += velocity * delta

func _draw() -> void:
	var body_rect: Rect2 = Rect2(-hitbox_size * 0.5, hitbox_size)
	var inner_rect: Rect2 = body_rect.grow_individual(-6.0, -4.0, -6.0, -4.0)
	var tint: Color = fill_color
	tint.a = 0.92
	draw_rect(body_rect, tint, true)
	var core_color: Color = Color.WHITE if not return_started else Color("d7f3ff")
	draw_rect(inner_rect, core_color, true)
