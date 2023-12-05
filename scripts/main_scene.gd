extends Node3D

func _ready() -> void:
	game_man.is_game_paused = false
	game_man.current_game_state = game_man.game_state.WaitingToStart
