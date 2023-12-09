extends Node

func _ready() -> void:
	for resource in DirAccess.get_files_at("res://"):
		if resource.ends_with(".remap"):
			resource = resource.replace(".remap", "")
	
