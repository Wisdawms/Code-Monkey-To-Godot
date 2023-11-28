class_name MyPlayerClass extends CharacterBody3D


@export var footstep_sounds_interval : float = 0.2
@onready var body_hit : Node3D
@onready var current_counter : BaseCounter
@onready var interact_raycast: RayCast3D = $Interact_Raycast
@onready var item_holding : BaseFood
@onready var hold_item_marker: Marker3D = $Hold_Item
@onready var footstep_timer : float = 0.0
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")


func handle_footstep_sounds(delta:float)->void:
	if is_walking():
		footstep_timer -= delta
		if footstep_timer < 0.0:
			footstep_timer = footstep_sounds_interval
			sound_man.play_audio_at_pos("footstep", self.position)
func _process(delta: float) -> void:
	handle_footstep_sounds(delta)
	handle_interactions()
	if hold_item_marker.get_child_count() != 0: # set player.item_holdign
		item_holding = hold_item_marker.get_child(-1)
	else: item_holding = null

func _physics_process(delta: float) -> void:
	move_and_slide()
	handle_gravity(delta)
	get_movement_velocity()
	handle_rotation(delta)
	handle_movement(delta)

func get_movement_velocity()->void:
	current_pos = global_position
	delta_pos = current_pos - last_pos
	last_pos = current_pos

#region vars for calculating player velocity
var current_pos : Vector3
var last_pos : Vector3
var delta_pos : Vector3
#endregion

#region movement related vars
@export var SPEED : float = 250
@export var FLOOR_FRICTION : float = 0.03
@export var player_rot_speed : float = 20.0
@export var gravity := 20.0
@export var ray_length := -0.2
@onready var moveDir := Vector3.ZERO
#endregion

func get_player_velocity() -> Vector2:
	return Vector2( abs(delta_pos.x), abs(delta_pos.z) )
func get_player_movement_direction() -> Vector3:
	return sign(delta_pos)
func is_walking() -> bool: 
	if get_player_velocity().x > 0.001: return true
	elif get_player_velocity().y > 0.001: return true
	return false
func handle_rotation(delta: float) -> void:
	var angle : float = atan2(moveDir.x, moveDir.z)
	var angle_delta : float = player_rot_speed * delta
	var r : float = rotation.y
	angle = lerp_angle(r, angle, 1.0)
	angle = clamp(angle, r - angle_delta, r + angle_delta)
	rotation.y = angle
	# or you can use this method: 
	#rotation.y = lerp_angle(rotation.y, atan2(moveDir.x, moveDir.z), player_rot_speed * delta) 
func handle_movement(delta: float) -> void:
	var input_vector : Vector2 = InputManager.vec_normalized()
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()

	#region if any key is pressed use the input_dir to give it to the player.moveDir that is used to move
	for action : String in InputMap.get_actions():
		if action == "forward" or action == "backward" or action == "right" or action == "left" :
			if Input.is_action_pressed(action):
				if direction:
					moveDir = Vector3(input_vector.x, 0, input_vector.y)
					velocity.x = moveDir.x * SPEED * delta
					velocity.z = moveDir.z * SPEED * delta
	#endregion
#region check if no key is pressed, then stop
	for action : String in InputMap.get_actions():
		if action == "forward" or action == "backward" or action == "right" or action == "left" :
			if !Input.is_action_pressed(action):
				if !direction:
					moveDir = lerp(moveDir, Vector3.ZERO, FLOOR_FRICTION)
					velocity.x = moveDir.x * SPEED * delta
					velocity.z = moveDir.z * SPEED * delta
func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
func handle_interactions()->void:
	if interact_raycast.is_colliding():
		#if interact_raycast.get_collision_normal() == Vector3.BACK:
		if interact_raycast.get_collider().get_parent().is_in_group("counters"):
			body_hit = interact_raycast.get_collider().get_parent()
			if body_hit  != current_counter:
				if current_counter:
					current_counter.emit_signal("OnUnhover", self)
				current_counter = body_hit
				current_counter.emit_signal("OnHover", self)
			if game_man.current_game_state != game_man.game_state.MainMenu and not game_man.is_game_playing(): return
			if Input.is_action_just_pressed("interact"):
				body_hit.emit_signal("OnInteract", self)
			elif Input.is_action_just_pressed("interact_alt"):
				body_hit.emit_signal("OnInteractAlt", self)
	else:
		if current_counter:
			current_counter.emit_signal("OnUnhover", self)
