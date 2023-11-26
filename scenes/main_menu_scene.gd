extends Control

@export var main_game_scene : PackedScene

func _on_start_button_pressed() -> void:
	Load.load_screen_to_scene(main_game_scene)

func _on_options_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()
