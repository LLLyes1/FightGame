extends RefCounted
class_name InputConfig

static func ensure_actions() -> void:
	var action_map := {
		"p1_left": [Key.KEY_A],
		"p1_right": [Key.KEY_D],
		"p1_jump": [Key.KEY_W],
		"p1_down": [Key.KEY_S],
		"p1_light": [Key.KEY_F],
		"p1_heavy": [Key.KEY_G],
		"p2_left": [Key.KEY_LEFT],
		"p2_right": [Key.KEY_RIGHT],
		"p2_jump": [Key.KEY_UP],
		"p2_down": [Key.KEY_DOWN],
		"p2_light": [Key.KEY_K],
		"p2_heavy": [Key.KEY_L],
		"pause_match": [Key.KEY_ESCAPE],
		"reset_match": [Key.KEY_R],
		"return_to_menu": [Key.KEY_TAB],
	}

	for action_name in action_map.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)

		if not InputMap.action_get_events(action_name).is_empty():
			continue

		for physical_key in action_map[action_name]:
			var event := InputEventKey.new()
			event.physical_keycode = physical_key
			InputMap.action_add_event(action_name, event)
