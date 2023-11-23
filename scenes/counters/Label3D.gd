extends Node3D
@onready var parent : BaseCounter = get_parent().get_parent()

func _process(delta: float) -> void:
	visible = parent.is_burning_meat
