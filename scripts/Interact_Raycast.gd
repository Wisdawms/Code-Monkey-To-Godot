extends RayCast3D

@onready var player: MyPlayerClass = $".."

func _process(_delta: float) -> void:
	for action : String in InputMap.get_actions():
		if action == "forward" or action == "backward" or action == "right" or action == "left" :
			if Input.is_action_pressed(action):
				rotation.y = atan2(player.moveDir.x, player.moveDir.z)
				global_position = player.global_position + ( Vector3(0,1,0) *.2 ) 
