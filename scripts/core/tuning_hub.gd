extends RefCounted
class_name TuningHub

const CAMERA := {
	"close_zoom": 1.0,
	"far_zoom": 0.55,
	"margin": Vector2(320.0, 220.0),
	"position_smoothing_speed": 5.0,
	"move_lerp_speed": 5.0,
	"zoom_lerp_speed": 3.0,
}

const MATCH_FLOW := {
	"fight_start_duration": 1.2,
	"training_reset_duration": 1.2,
	"training_reset_respawn_delay": 0.75,
	"ring_out_duration": 1.5,
	"ring_out_respawn_delay": 1.0,
	"match_result_duration": 999.0,
}

const HUD_FEEDBACK := {
	"fight_start_color": Color("e0fbfc"),
	"fight_start_font_size": 30,
	"training_reset_color": Color("7bdff2"),
	"training_reset_font_size": 24,
	"ring_out_color": Color("ff9f1c"),
	"ring_out_font_size": 26,
	"match_result_color": Color("f8f9fa"),
	"match_result_font_size": 30,
	"training_hit_callout_duration": 0.9,
	"versus_hit_callout_duration": 1.1,
	"training_hit_callout_font_size": 22,
	"versus_hit_callout_font_size": 28,
	"projectile_hit_color": Color("7bdff2"),
	"heavy_hit_color": Color("ff9f1c"),
	"medium_hit_color": Color("ffe066"),
	"light_hit_color": Color("f8f9fa"),
}

const FIGHTER_RUNTIME := {
	"jump_release_velocity_ratio": 0.55,
	"attack_buffer_seconds": 0.20,
	"hurt_air_drag_scale": 0.35,
	"heavy_hit_flash_seconds": 0.16,
	"default_hit_flash_seconds": 0.10,
	"hit_flash_blend_speed": 5.0,
	"hit_flash_max_blend": 0.65,
	"fallback_heavy_hit_flash_color": Color("ffd166"),
	"fallback_default_hit_flash_color": Color("7bdff2"),
}
