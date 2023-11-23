extends Camera3D

@export var player : Node3D
@onready var cam_offset : Vector3 = position
@export_range(2, 10) var camera_follow_elasticity : float = 8

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var position_with_offset : Vector3 = player.position + cam_offset
	position = lerp(position, position_with_offset, camera_follow_elasticity * delta)
