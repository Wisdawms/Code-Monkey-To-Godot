extends Control

@export var main_game_scene : PackedScene

func _ready() -> void:
	Engine.time_scale = 1.0

func _on_start_button_pressed() -> void:
	Load.load_screen_to_scene(main_game_scene)

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_options_button_pressed() -> void:
	game_man.paused_ui.visible = true # whole container
	game_man.paused_content.visible = false # useless in main menu
	game_man.options_ui.visible = true # what we want
	game_man.bg_veil.visible = true
