extends Node

@onready var loading_scene = preload("res://scenes/loading_scene.tscn")
@onready var music_man = Globals.find_node("MusicManager")

func load_screen_to_scene(target_scene):
	get_tree().change_scene_to_packed(loading_scene)

func _process(delta: float) -> void:
	if get_tree().current_scene:
		if get_tree().current_scene.name != "loading_scene" and music_man.get_child(-1).stream_paused != false:
			music_man.get_child(-1).stream_paused = false
			print("playing music")
		elif get_tree().current_scene.name == "loading_scene" and music_man.get_child(-1).stream_paused != true:
			music_man.get_child(-1).stream_paused = true
			print("paused music")
