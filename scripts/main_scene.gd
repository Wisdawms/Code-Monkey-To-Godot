extends Node3D


# this is faster, because it doesn't run every frame
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			get_tree().quit()

