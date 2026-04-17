extends Node2D
class_name Projectile

var source_fighter = null
var owner_slot: int = -1
var velocity: Vector2 = Vector2.ZERO
var lifetime: float = 1.0
var payload: Dictionary = {}
var hitbox_size: Vector2 = Vector2(48.0, 24.0)
var fill_color: Color = Color.WHITE

func configure(attacker, attack_data: Dictionary) -> void:
	source_fighter = attacker
	owner_slot = attacker.player_slot
	fill_color = attacker.body_accent_color
	payload = {
		"damage": attack_data.get("damage", 8.0),
		"base_knockback": attack_data.get("base_knockback", 540.0),
		"knockback_growth": attack_data.get("knockback_growth", 6.4),
		"launch_angle": attack_data.get("launch_angle", 16.0),
		"hitstun": attack_data.get("hitstun", 0.18),
	}
	hitbox_size = attack_data.get("hitbox_size", Vector2(48.0, 24.0))
	lifetime = attack_data.get("projectile_lifetime", 1.0)
	velocity = Vector2(attack_data.get("projectile_speed", 900.0) * attacker.facing, 0.0)
	global_position = attacker.global_position + Vector2(
		attack_data.get("hitbox_offset", Vector2.ZERO).x * attacker.facing,
		attack_data.get("hitbox_offset", Vector2.ZERO).y
	)
	queue_redraw()

func _physics_process(delta: float) -> void:
	position += velocity * delta
	lifetime -= delta

	if lifetime <= 0.0:
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
		if get_hitbox_rect().intersects(node.get_hurtbox_rect()):
			node.receive_hit(payload, source_fighter)
			queue_free()
			return

	queue_redraw()

func get_hitbox_rect() -> Rect2:
	return Rect2(global_position - hitbox_size * 0.5, hitbox_size)

func _draw() -> void:
	var body_rect: Rect2 = Rect2(-hitbox_size * 0.5, hitbox_size)
	var inner_rect: Rect2 = body_rect.grow_individual(-6.0, -4.0, -6.0, -4.0)
	var tint: Color = fill_color
	tint.a = 0.92
	draw_rect(body_rect, tint, true)
	draw_rect(inner_rect, Color.WHITE, true)
