extends Node2D
class_name Stage

const MAIN_PLATFORM := Rect2(-520.0, 320.0, 1040.0, 42.0)
const LEFT_PLATFORM := Rect2(-760.0, 140.0, 280.0, 22.0)
const RIGHT_PLATFORM := Rect2(480.0, 140.0, 280.0, 22.0)
const BLAST_ZONE := Rect2(-1500.0, -900.0, 3000.0, 1900.0)
const CAMERA_ZONE := Rect2(-1420.0, -820.0, 2840.0, 1660.0)
const SPAWN_POINTS := [Vector2(-260.0, 180.0), Vector2(260.0, 180.0)]

func _ready() -> void:
	_build_platform("MainPlatform", MAIN_PLATFORM, false)
	_build_platform("LeftPlatform", LEFT_PLATFORM, true)
	_build_platform("RightPlatform", RIGHT_PLATFORM, true)
	queue_redraw()

func get_spawn_point(index: int) -> Vector2:
	return SPAWN_POINTS[clamp(index, 0, SPAWN_POINTS.size() - 1)]

func is_inside_blast_zone(world_position: Vector2) -> bool:
	return BLAST_ZONE.has_point(world_position)

func get_camera_zone() -> Rect2:
	return CAMERA_ZONE

func _build_platform(platform_name: String, rect: Rect2, one_way: bool) -> void:
	var body := StaticBody2D.new()
	body.name = platform_name
	body.position = rect.position + rect.size * 0.5

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	collision.one_way_collision = one_way
	collision.one_way_collision_margin = 3.0

	body.add_child(collision)
	add_child(body)

func _draw() -> void:
	draw_rect(Rect2(-1800.0, -1100.0, 3600.0, 2400.0), Color("0b1620"), true)
	draw_rect(Rect2(-1800.0, 360.0, 3600.0, 1400.0), Color("102433"), true)
	draw_rect(MAIN_PLATFORM, Color("2c4a5f"), true)
	draw_rect(MAIN_PLATFORM.grow(-8.0), Color("f4d35e"), true)
	draw_rect(LEFT_PLATFORM, Color("315c73"), true)
	draw_rect(LEFT_PLATFORM.grow(-6.0), Color("faf0ca"), true)
	draw_rect(RIGHT_PLATFORM, Color("315c73"), true)
	draw_rect(RIGHT_PLATFORM.grow(-6.0), Color("faf0ca"), true)

	var blast_outline := Color("ee964b")
	blast_outline.a = 0.14
	draw_rect(BLAST_ZONE, blast_outline, false, 6.0)
