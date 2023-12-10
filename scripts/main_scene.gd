extends Node3D

func _ready() -> void:
	game_man.initialize_game_start()
	PlayerPrefs.save_data()
	game_man.seen_tut = PlayerPrefs.get_pref("seen_tutorial", false)
