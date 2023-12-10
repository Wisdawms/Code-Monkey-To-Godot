extends Node3D

@export var main_game_scene : PackedScene

func _ready() -> void:
	for child in sound_man.get_children():
		sound_man.remove_child(child)
	game_man.update_current_menu_state()
	game_man.is_game_paused = true
	game_man.game_starting_ui.visible = false
	game_man.current_menu_state = game_man.menu_state.NONE
	Engine.time_scale = 1.0


func _on_start_button_button_up() -> void:
	Load.load_screen_to_scene(main_game_scene)
	


func _on_options_button_button_up() -> void:
	game_man.current_menu_state = game_man.menu_state.OptionsMenu
	game_man.update_current_menu_state()


func _on_quit_button_button_up() -> void:
	get_tree().quit()
