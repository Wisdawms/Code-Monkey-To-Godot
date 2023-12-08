extends Button

@export var action_name : String
@export var is_joy: bool = false
# default key for this action

var do_set : bool = false

func _ready() -> void:
	PlayerPrefs.delete_all()
	init_keybindings()
	if not is_joy:
		text = OS.get_keycode_string(InputMap.action_get_events(action_name)[1].keycode)
	elif is_joy:
		if InputMap.action_get_events(action_name)[0] is InputEventJoypadButton:
			var raw_joy : String = InputMap.action_get_events(action_name)[0].as_text()
			text = get_xbox_button_name("Xbox", raw_joy)
		elif InputMap.action_get_events(action_name)[0] is InputEventJoypadMotion:
			var raw_joy : String = InputMap.action_get_events(action_name)[0].as_text()
			text = get_Joybutton_name(raw_joy)

func _on_button_up() -> void:
	text = ".."
	do_set = true

func _input(event: InputEvent) -> void:
	if do_set:
		if Input.is_action_just_pressed("escape"):
			if not is_joy:
				text = OS.get_keycode_string(InputMap.action_get_events(action_name)[1].keycode)
			elif is_joy:
				var raw_joy : String = InputMap.action_get_events(action_name)[0].as_text()
				text = get_xbox_button_name("Xbox", raw_joy)
			do_set = false
			return
		if event is InputEventKey and not is_joy:
			InputMap.action_erase_event(action_name, InputMap.action_get_events(action_name)[1])
			InputMap.action_add_event(action_name, event)
			text = OS.get_keycode_string(event.keycode)
			PlayerPrefs.set_pref(action_name, event.keycode)
			PlayerPrefs.save_data()
			do_set = false
		elif event is InputEventJoypadButton and is_joy:
			var kb_binding : InputEventKey = InputMap.action_get_events(action_name)[1] # get the keyboard button and save it to a variable
			InputMap.action_erase_events(action_name)
			InputMap.action_add_event(action_name, event)
			InputMap.action_add_event(action_name, kb_binding)
			var raw_joy : String = InputMap.action_get_events(action_name)[0].as_text()
			if raw_joy.contains("D-pad"):
				text = get_dpad_button_name(raw_joy)
			else:
				text = get_xbox_button_name("Xbox", raw_joy)
			PlayerPrefs.set_pref(action_name, event.button_index)
			PlayerPrefs.save_data()
			do_set = false
		elif event is InputEventJoypadMotion and is_joy:
			var kb_binding : InputEventKey = InputMap.action_get_events(action_name)[1] # get the keyboard button and save it to a variable
			InputMap.action_erase_events(action_name)
			InputMap.action_add_event(action_name, event)
			InputMap.action_add_event(action_name, kb_binding)
			var raw_joy : String = InputMap.action_get_events(action_name)[0].as_text()
			text = get_Joybutton_name(raw_joy)
			PlayerPrefs.set_pref(action_name, event.axis_value)
			PlayerPrefs.save_data()
			do_set = false
func init_keybindings()->void:
	var new_event : InputEventKey = InputEventKey.new()
	new_event.keycode = PlayerPrefs.get_pref(action_name, InputMap.action_get_events(action_name)[1].keycode)
	InputMap.action_erase_event(action_name, InputMap.action_get_events(action_name)[1])
	InputMap.action_add_event(action_name, new_event)
	PlayerPrefs.load_data()
	
func get_xbox_button_name(controller_kind: String, raw_button_name: String) -> String:
	var start_position := raw_button_name.find(controller_kind)
	var end_position := raw_button_name.find(",", start_position)
	return raw_button_name.substr(start_position, end_position - start_position)

func get_dpad_button_name(raw_button_name: String) -> String:
	var start_position := raw_button_name.find("D-pad")
	var end_position := raw_button_name.find(")", start_position)
	return raw_button_name.substr(start_position, end_position - start_position)
	
func get_Joybutton_name(raw_button_name: String) -> String:
	var new_event : InputEventJoypadButton = InputEventJoypadButton.new()
	if raw_button_name.contains("Joypad Motion on Axis 1 (Left Stick Y-Axis, Joystick 0 Y-Axis)"):
		if InputMap.action_get_events(action_name)[0].axis_value < 0.00:
			new_event.button_index = 11
			InputMap.action_add_event(action_name, new_event)
			return "Left Joystick Up"
		elif InputMap.action_get_events(action_name)[0].axis_value > 0.00:
			new_event.button_index = 12
			InputMap.action_add_event(action_name, new_event)
			return "Left Joystick Down"
	if raw_button_name.contains ("Joypad Motion on Axis 0 (Left Stick X-Axis, Joystick 0 X-Axis)"):
		if InputMap.action_get_events(action_name)[0].axis_value < 0.00:
			new_event.button_index = 13
			InputMap.action_add_event(action_name, new_event)
			return "Left Joystick Left"
		elif InputMap.action_get_events(action_name)[0].axis_value > 0.00:
			new_event.button_index = 14
			InputMap.action_add_event(action_name, new_event)
			return "Left Joystick Right"
	print(InputMap.action_get_events(action_name)[0].axis_value)
	return InputMap.action_get_events(action_name)[0].as_text()
	
