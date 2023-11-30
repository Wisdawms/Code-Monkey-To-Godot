class_name InputHandler extends Node


var last_dir := Vector2.ZERO
const diagonal_vector := 0.71

func vec_normalized() -> Vector2:
	if game_man.current_menu_state != game_man.menu_state.NONE:
		return Vector2.ZERO
	var input_vector : Vector2 = Vector2.ZERO

	input_vector = Vector2( 
		Input.get_axis( "left", "right" ), 
		Input.get_axis( "forward", "backward" ) 
		)
		
	if input_vector:
		last_dir = input_vector
	# normalize input vector
	input_vector = input_vector.normalized()
	return input_vector
#enum directions {
	#UP,
	#DOWN,
	#LEFT,
	#RIGHT,
	#RIGHT_UP,
	#LEFT_UP,
	#RIGHT_DOWN,
	#LEFT_DOWN
#}
#
#var direction := directions.DOWN
#
#func get_direction()-> String:
	#match round_to_dec( vec_normalized(), 2 ):
		#Vector2(diagonal_vector, diagonal_vector): 
			#direction = directions.RIGHT_DOWN
		#Vector2(diagonal_vector, -diagonal_vector): 
			#direction = directions.RIGHT_UP
		#Vector2(-diagonal_vector, diagonal_vector): 
			#direction = directions.LEFT_DOWN
		#Vector2(-diagonal_vector, -diagonal_vector): 
			#direction = directions.LEFT_UP
		#
		#Vector2.DOWN: 
			#direction = directions.DOWN
		#Vector2.UP:
			#direction = directions.UP
		#Vector2.RIGHT:
			#direction = directions.RIGHT
		#Vector2.LEFT:
			#direction = directions.LEFT
	#return directions.keys()[direction]

#func round_to_dec(num, digit):
	#return round(num * pow(10.0, 2)) / pow(10.0, 2)
