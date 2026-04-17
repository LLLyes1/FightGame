extends Node

const GAME_SCENE = preload("res://scenes/game/game_scene.tscn")

var game_root: Node = null
var menu_layer: CanvasLayer = null
var versus_button: Button = null
var training_button: Button = null
var result_label: Label = null

var current_game = null
var last_result_text := "按上面的按钮启动原型。"

func _ready() -> void:
	game_root = get_node_or_null("GameRoot")
	menu_layer = get_node_or_null("MenuLayer") as CanvasLayer
	versus_button = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/Buttons/VersusButton") as Button
	training_button = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/Buttons/TrainingButton") as Button
	result_label = get_node_or_null("MenuLayer/Menu/Center/Panel/Margin/VBox/ResultLabel") as Label

	if game_root == null or menu_layer == null or versus_button == null or training_button == null or result_label == null:
		push_error("Main scene nodes are missing. Check scenes/main/main.tscn structure.")
		return

	versus_button.pressed.connect(_on_start_versus_pressed)
	training_button.pressed.connect(_on_start_training_pressed)
	result_label.text = last_result_text

func _on_start_versus_pressed() -> void:
	_launch_game("versus")

func _on_start_training_pressed() -> void:
	_launch_game("training")

func _launch_game(mode: String) -> void:
	if current_game and is_instance_valid(current_game):
		current_game.queue_free()

	current_game = GAME_SCENE.instantiate()
	current_game.start_mode = mode
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
	last_result_text = "%s\n按 Tab 返回菜单或在场内按 R 重开。" % result_text
