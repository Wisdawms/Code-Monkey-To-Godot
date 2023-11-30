extends Button

@export var action_name : String
# default key for this action

var do_set : bool = false

func _ready() -> void:
	init_keybindings()
	text = OS.get_keycode_string(InputMap.action_get_events(action_name)[1].keycode) # default key

func _on_button_up() -> void:
	text = ".."
	do_set = true



func _input(event: InputEvent) -> void:
	if do_set:
		if event is InputEventKey:
			if event.keycode == KEY_ESCAPE:
				text = OS.get_keycode_string(InputMap.action_get_events(action_name)[1].keycode)
				do_set = false
				return
			InputMap.action_erase_events(action_name)
			InputMap.action_add_event(action_name, event)
			text = OS.get_keycode_string(event.keycode)
			PlayerPrefs.set_pref(action_name, event.keycode)
			PlayerPrefs.save_data()
			do_set = false
			
func init_keybindings()->void:
	var new_event : InputEventKey = InputEventKey.new()
	new_event.keycode = PlayerPrefs.get_pref(action_name, InputMap.action_get_events(action_name)[1].keycode)
	InputMap.action_erase_event(action_name, InputMap.action_get_events(action_name)[1])
	InputMap.action_add_event(action_name, new_event)
	PlayerPrefs.load_data()

