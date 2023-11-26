extends Node

@onready var loading_scene = preload("res://scenes/loading_scene.tscn")

func load_screen_to_scene(target_scene):
	get_tree().change_scene_to_packed(loading_scene)
