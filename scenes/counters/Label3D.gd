extends Node3D
@onready var parent : BaseCounter = get_parent().get_parent()

func _process(_delta: float) -> void:
	match parent.is_burning_meat:
		false:
			if visible != false:
				visible = false
		true:
			if visible != true:
				visible = true
	
func _ready()->void:
	get_child(0).texture = get_child(0).get_child(0).get_texture()
	get_child(0).material_override.albedo_texture = get_child(0).get_child(0).get_texture()
