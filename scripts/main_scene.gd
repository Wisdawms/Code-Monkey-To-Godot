extends Node3D

func _ready() -> void:
	game_man.initialize_game_start()
	game_man.current_game_state = game_man.game_state.WaitingToStart

