extends Node2D
class_name Stage

const WORLD_BOUNDS := Rect2(-1920.0, -1180.0, 3840.0, 2480.0)
const BLAST_ZONE := Rect2(-1620.0, -980.0, 3240.0, 2080.0)
const CAMERA_ZONE := Rect2(-1500.0, -880.0, 3000.0, 1760.0)
const SPAWN_POINTS := [Vector2(-220.0, 210.0), Vector2(220.0, 210.0)]

const MAIN_PLATFORM := Rect2(-600.0, 332.0, 1200.0, 44.0)
const LEFT_PLATFORM := Rect2(-720.0, 196.0, 280.0, 22.0)
const RIGHT_PLATFORM := Rect2(440.0, 126.0, 280.0, 22.0)

var platform_layout: Array[Dictionary] = []

func _ready() -> void:
	platform_layout = [
		_make_platform_data("MainPlatform", MAIN_PLATFORM, false, Color("2c4a5f"), Color("193647"), Color("f4d35e"), 8.0),
		_make_platform_data("LeftPlatform", LEFT_PLATFORM, true, Color("315c73"), Color("17384c"), Color("faf0ca"), 6.0),
		_make_platform_data("RightPlatform", RIGHT_PLATFORM, true, Color("315c73"), Color("17384c"), Color("faf0ca"), 6.0),
	]

	for platform in platform_layout:
		_build_platform(platform)

	queue_redraw()

func get_spawn_point(index: int) -> Vector2:
	return SPAWN_POINTS[clamp(index, 0, SPAWN_POINTS.size() - 1)]

func is_inside_blast_zone(world_position: Vector2) -> bool:
	return BLAST_ZONE.has_point(world_position)

func get_camera_zone() -> Rect2:
	return CAMERA_ZONE

func _make_platform_data(
	platform_name: String,
	rect: Rect2,
	one_way: bool,
	shell_color: Color,
	fill_color: Color,
	accent_color: Color,
	trim_size: float
) -> Dictionary:
	return {
		"name": platform_name,
		"rect": rect,
		"one_way": one_way,
		"shell": shell_color,
		"fill": fill_color,
		"accent": accent_color,
		"trim": trim_size,
	}

func _build_platform(platform: Dictionary) -> void:
	var rect: Rect2 = platform["rect"]
	var body := StaticBody2D.new()
	body.name = String(platform["name"])
	body.position = rect.position + rect.size * 0.5

	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	collision.shape = shape
	collision.one_way_collision = bool(platform["one_way"])
	collision.one_way_collision_margin = 3.0

	body.add_child(collision)
	add_child(body)

func _draw() -> void:
	_draw_backdrop()
	_draw_support_architecture()

	for platform in platform_layout:
		_draw_platform(platform)

	_draw_blast_outline()

func _draw_backdrop() -> void:
	draw_rect(WORLD_BOUNDS, Color("08131d"), true)
	draw_rect(Rect2(WORLD_BOUNDS.position.x, WORLD_BOUNDS.position.y, WORLD_BOUNDS.size.x, 560.0), Color("102534"), true)
	draw_rect(Rect2(WORLD_BOUNDS.position.x, -120.0, WORLD_BOUNDS.size.x, 520.0), Color("173248"), true)
	draw_rect(Rect2(WORLD_BOUNDS.position.x, 360.0, WORLD_BOUNDS.size.x, 940.0), Color("0f2231"), true)

	var glow := Color("f4d35e")
	glow.a = 0.16
	draw_circle(Vector2(0.0, -420.0), 170.0, glow)

	var halo := Color("faf0ca")
	halo.a = 0.10
	draw_circle(Vector2(0.0, -420.0), 260.0, halo)

	var ridge_back := PackedVector2Array([
		Vector2(-1920.0, 250.0),
		Vector2(-1500.0, 90.0),
		Vector2(-1180.0, 180.0),
		Vector2(-820.0, 30.0),
		Vector2(-420.0, 150.0),
		Vector2(-120.0, 10.0),
		Vector2(220.0, 170.0),
		Vector2(640.0, 20.0),
		Vector2(1060.0, 210.0),
		Vector2(1420.0, 70.0),
		Vector2(1920.0, 250.0),
		Vector2(1920.0, 820.0),
		Vector2(-1920.0, 820.0),
	])
	draw_colored_polygon(ridge_back, Color("10283b"))

	var ridge_front := PackedVector2Array([
		Vector2(-1920.0, 360.0),
		Vector2(-1600.0, 250.0),
		Vector2(-1260.0, 340.0),
		Vector2(-900.0, 190.0),
		Vector2(-540.0, 320.0),
		Vector2(-180.0, 170.0),
		Vector2(180.0, 300.0),
		Vector2(520.0, 180.0),
		Vector2(860.0, 320.0),
		Vector2(1220.0, 220.0),
		Vector2(1600.0, 340.0),
		Vector2(1920.0, 270.0),
		Vector2(1920.0, 940.0),
		Vector2(-1920.0, 940.0),
	])
	draw_colored_polygon(ridge_front, Color("16364b"))

	for tower in _get_tower_rects():
		draw_rect(tower, Color("1c4057"), true)
		var tower_glow := Rect2(tower.position + Vector2(10.0, 12.0), Vector2(tower.size.x - 20.0, maxf(tower.size.y - 48.0, 16.0)))
		draw_rect(tower_glow, Color("244f68"), true)

func _get_tower_rects() -> Array[Rect2]:
	return [
		Rect2(-1340.0, 80.0, 88.0, 320.0),
		Rect2(-1040.0, 130.0, 72.0, 270.0),
		Rect2(968.0, 112.0, 72.0, 288.0),
		Rect2(1252.0, 72.0, 88.0, 328.0),
	]

func _draw_support_architecture() -> void:
	var main_base := Rect2(MAIN_PLATFORM.position.x + 84.0, MAIN_PLATFORM.end.y, MAIN_PLATFORM.size.x - 168.0, 148.0)
	draw_rect(main_base, Color("163547"), true)
	draw_rect(Rect2(main_base.position + Vector2(18.0, 14.0), main_base.size - Vector2(36.0, 28.0)), Color("214b62"), true)

	var support_columns := [
		Rect2(MAIN_PLATFORM.position.x + 116.0, MAIN_PLATFORM.end.y + 24.0, 84.0, 190.0),
		Rect2(-42.0, MAIN_PLATFORM.end.y + 12.0, 84.0, 202.0),
		Rect2(MAIN_PLATFORM.end.x - 200.0, MAIN_PLATFORM.end.y + 24.0, 84.0, 190.0),
	]
	for column in support_columns:
		draw_rect(column, Color("102a3b"), true)
		draw_rect(Rect2(column.position + Vector2(12.0, 0.0), Vector2(column.size.x - 24.0, column.size.y)), Color("29526a"), true)

	var apron_shadow := Rect2(-1920.0, MAIN_PLATFORM.end.y + 218.0, 3840.0, 1060.0)
	draw_rect(apron_shadow, Color("0b1620"), true)

	_draw_platform_anchor(LEFT_PLATFORM, Vector2(-34.0, -180.0))
	_draw_platform_anchor(RIGHT_PLATFORM, Vector2(34.0, -210.0))

	var edge_beacon_color := Color("f95738")
	draw_circle(Vector2(MAIN_PLATFORM.position.x + 46.0, MAIN_PLATFORM.position.y - 26.0), 10.0, edge_beacon_color)
	draw_circle(Vector2(MAIN_PLATFORM.end.x - 46.0, MAIN_PLATFORM.position.y - 26.0), 10.0, edge_beacon_color)

func _draw_platform_anchor(platform_rect: Rect2, anchor_offset: Vector2) -> void:
	var anchor_point := platform_rect.position + Vector2(platform_rect.size.x * 0.5, 0.0) + anchor_offset
	var left_chain_end := platform_rect.position + Vector2(34.0, 2.0)
	var right_chain_end := platform_rect.position + Vector2(platform_rect.size.x - 34.0, 2.0)
	draw_line(anchor_point, left_chain_end, Color("4f7184"), 4.0)
	draw_line(anchor_point, right_chain_end, Color("4f7184"), 4.0)
	draw_circle(anchor_point, 8.0, Color("faf0ca"))

func _draw_platform(platform: Dictionary) -> void:
	var rect: Rect2 = platform["rect"]
	var shell_color: Color = platform["shell"]
	var fill_color: Color = platform["fill"]
	var accent_color: Color = platform["accent"]
	var trim_size: float = float(platform["trim"])

	draw_rect(rect, shell_color, true)
	draw_rect(rect.grow(-trim_size), fill_color, true)
	draw_rect(Rect2(rect.position + Vector2(trim_size, 4.0), Vector2(rect.size.x - trim_size * 2.0, 6.0)), accent_color, true)
	draw_line(
		Vector2(rect.position.x + trim_size, rect.end.y - 4.0),
		Vector2(rect.end.x - trim_size, rect.end.y - 4.0),
		Color("0f2231"),
		3.0
	)

func _draw_blast_outline() -> void:
	var blast_outline := Color("ee964b")
	blast_outline.a = 0.14
	draw_rect(BLAST_ZONE, blast_outline, false, 6.0)
