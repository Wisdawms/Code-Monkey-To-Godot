extends Node3D

@onready var stove_on_visual: StaticBody3D = $StoveOnVisual

@export var Stove_On : bool = false

func _process(delta: float) -> void:
	stove_on_visual.visible = Stove_On


