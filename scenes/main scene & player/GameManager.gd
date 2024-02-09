class_name GameManager extends Node

@onready var bg_veil : ColorRect = get_node("CanvasLayer/bg_veil")
@onready var game_starting_ui : Control = get_node("CanvasLayer/game_starting_ui")
@onready var countdown_timer_text : Label = get_node("CanvasLayer/game_starting_ui/countdown_timer_text")
@onready var game_starting_text : Label = get_node("CanvasLayer/game_starting_ui/game_starting_text")
@onready var game_over_ui : Control = get_node("CanvasLayer/game_over_ui")
@onready var gameover_recipes_number : Label = get_node("CanvasLayer/game_over_ui/gameover_recipes_number")
@onready var gameover_money_made: Label = get_node("CanvasLayer/game_over_ui/gameover_money_made")
@onready var game_progress : TextureProgressBar = get_node("CanvasLayer/game_playing_ui/game_progress")
@onready var game_playing_ui : MarginContainer = get_node("CanvasLayer/game_playing_ui")
@onready var paused_ui : Control = get_node("CanvasLayer/paused_ui")
@onready var music_volume_button: Button = $CanvasLayer/paused_ui/options_ui/options_content/music_volume_button
@onready var sound_effects_volume_button: Button = $CanvasLayer/paused_ui/options_ui/options_content/sound_effects_volume_button
@onready var back_button: Button = $CanvasLayer/paused_ui/options_ui/options_content/back_button
@onready var paused_content: Control = $CanvasLayer/paused_ui/paused_content
@export var main_menu_scene : String = "res://scenes/main_menu_scene.tscn"
@onready var options_ui: Control = $CanvasLayer/paused_ui/options_ui
@onready var keybindings_menu: Control = $CanvasLayer/paused_ui/keybindings_menu


var orig_progress_alpha : float
var orig_under_alpha : float

signal StateChanged
signal OnGamePaused
signal OnGameUnpaused

var seen_tut : bool = false

enum game_state {
	MainMenu,
	Tutorial,
	WaitingToStart,
	CountdownToStart,
	GamePlaying,
	GameOver,
}
@onready var current_game_state : game_state = game_state.MainMenu

enum menu_state{
	NONE,
	PauseMenu,
	OptionsMenu,
	KeybindingsMenu,
}
@onready var current_menu_state : menu_state = menu_state.NONE

@onready var is_game_paused : bool = false
@export var intermission_timer : float = 1.0
var game_start_timer : float
@export var default_game_start_time : float = 3.0
@export var game_playing_time_max : float = 10.0
@onready var game_playing_timer : float
@onready var once : bool = true
@onready var original_alpha:float = game_progress.tint_progress.a
var flickering_timer : float = 0.0
var flickering_interval : float = 0.2

func _process(delta: float) -> void:
	if current_game_state == game_state.MainMenu and $CanvasLayer/tut.visible != false :
		bg_veil.visible = false
		$CanvasLayer/tut.visible = false
	yup()
	if current_game_state == game_state.MainMenu: return
	if is_game_playing() and not is_game_paused:
		bg_veil.visible = false
		if is_game_almost_over():
			if game_progress.tint_progress != Color.RED :
				game_progress.tint_progress.r = 1.0
				game_progress.tint_progress.g = 0.0
				game_progress.tint_progress.b = 0.0
			flash(delta)
	elif current_game_state != game_state.MainMenu and is_game_paused or not is_game_playing():
		bg_veil.visible = true
	match current_game_state:
		game_state.Tutorial:
			Engine.time_scale = 0.0
			bg_veil.visible = true
			$CanvasLayer/tut.visible = true
			if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("escape"):
				initialize_game_start()
		game_state.WaitingToStart:
			if not is_game_paused:
				Engine.time_scale = 1.0
			$CanvasLayer/tut.visible = false
			intermission_timer -= delta
			countdown_timer_text.visible = false
			game_starting_ui.visible = true
			game_starting_text.visible = true
			if intermission_timer < 0.0:
				current_game_state = game_state.CountdownToStart
				game_playing_ui.visible = true
				StateChanged.emit()
		game_state.CountdownToStart:
			game_start_timer -= delta
			if game_start_timer < 0.0:
				current_game_state = game_state.GamePlaying
				game_playing_timer = game_playing_time_max
				StateChanged.emit()
		game_state.GamePlaying:
			game_playing_timer -= delta
			game_progress.value = ( 1- ( game_playing_timer / game_playing_time_max ) ) * game_progress.max_value
			if game_playing_timer < 0.0:
				current_game_state = game_state.GameOver
				StateChanged.emit()
		game_state.GameOver:
			if once:
				StateChanged.emit()
				game_playing_ui.visible = false
				once = false

	if countdown_timer_text.text != str(ceil(game_start_timer)):
		countdown_timer_text.text = str(ceil(game_start_timer))

func is_game_playing()->bool:
	return current_game_state == game_state.GamePlaying
func is_countdown_to_start()->bool:
	return current_game_state == game_state.CountdownToStart
func is_game_starting()->bool:
	return current_game_state == game_state.WaitingToStart
func is_game_over()->bool:
	return current_game_state == game_state.GameOver

func _ready() -> void:
	if PlayerPrefs.get_pref("seen_tutorial", seen_tut) != null:
		seen_tut = PlayerPrefs.get_pref("seen_tutorial", seen_tut)
	else: seen_tut = false
	if get_tree().current_scene and get_tree().current_scene.name == "main_menu_scene":
		Globals.find_node("StartButton").grab_focus()
	update_current_menu_state()
	orig_progress_alpha = game_progress.tint_progress.a
	orig_under_alpha = game_progress.tint_under.a
	OnGamePaused.connect(show_pause_ui)
	OnGameUnpaused.connect(hide_pause_ui)
	StateChanged.connect(update_game_manager_ui)
	countdown_timer_text.visible = false
	game_over_ui.visible = false
	game_playing_ui.visible = false
	paused_ui.visible = false
	game_starting_ui.visible = false
	
func update_game_manager_ui()->void:
	if get_tree().current_scene and get_tree().current_scene.name == "main_menu_scene": return
	if is_game_starting() and not is_game_paused:
		game_starting_text.visible = true
	else: game_starting_text.visible = false
	if is_countdown_to_start():
		countdown_timer_text.visible = true
	else:
		countdown_timer_text.visible = false
	if is_game_over():
		game_over_ui.visible = true
		$CanvasLayer/game_over_ui/RestartButton.grab_focus()
		if gameover_recipes_number.text != str(dev_man.orders_delivered):
			gameover_recipes_number.text = str(dev_man.orders_delivered)
		if gameover_money_made.text != dev_man.get_formatted_money():
			gameover_money_made.text = dev_man.get_formatted_money()
	else: game_over_ui.visible = false

func is_game_almost_over()->bool:
	return game_playing_timer < game_playing_time_max * .30

func flash(delta:float)->void:
	flickering_timer += delta
	if flickering_timer >= flickering_interval:
		flickering_timer = 0.0
		toggle_visibility()
		
func toggle_visibility()->void:
	if game_progress.tint_progress.a == 0.0:
		game_progress.tint_progress.a = original_alpha
	else:
		game_progress.tint_progress.a = 0.0


func yup() -> void:
	if Input.is_action_just_pressed("escape") and current_game_state != game_state.Tutorial:
		if get_tree().current_scene.name == "main_menu_scene":
			if current_menu_state == menu_state.OptionsMenu:
				current_menu_state = menu_state.NONE
				update_current_menu_state()
				return
			else:
				current_menu_state -= 1
				update_current_menu_state()
		else:
			if current_menu_state == menu_state.NONE:
				toggle_pause_game()
				update_current_menu_state()
			elif current_menu_state == menu_state.PauseMenu:
				toggle_pause_game()
				update_current_menu_state()
			else:
				if current_menu_state != menu_state.NONE:
					current_menu_state -= 1
					update_current_menu_state()

func toggle_pause_game()->void:
	is_game_paused = !is_game_paused
	if is_game_paused:
		Engine.time_scale = 0.0
		OnGamePaused.emit()
		if is_game_starting() or is_countdown_to_start() and game_starting_ui.visible != false:
			bg_veil.visible = true
			game_starting_ui.visible = false
			game_progress.tint_progress.a = 0.0
			game_progress.tint_under.a = 0.0
		if is_game_over() and game_over_ui.visible != false:
			game_over_ui.visible = false
			bg_veil.visible = true
	else:
		Engine.time_scale = 1.0
		OnGameUnpaused.emit()
		if is_game_starting() or is_countdown_to_start() and game_starting_ui.visible != true:
			game_starting_ui.visible = true
			game_progress.tint_progress.a = 0.59
			game_progress.tint_under.a = orig_under_alpha
		if is_game_over() and game_over_ui.visible != true:
			game_over_ui.visible = true

func show_pause_ui()->void:
	current_menu_state += 1
	bg_veil.visible = true
	update_current_menu_state()
	if is_game_starting():
		game_starting_text.visible = false
func hide_pause_ui()->void:
	current_menu_state = menu_state.NONE
	update_current_menu_state()
	if is_game_starting():
		game_starting_text.visible = true


func _on_restart_button_pressed() -> void:
	restart_level()
	update_current_menu_state()

func _on_keybindings_button_pressed() -> void:
	current_menu_state = menu_state.KeybindingsMenu
	update_current_menu_state()

func update_current_menu_state()->void:
	match current_menu_state:
		menu_state.NONE:
			paused_ui.visible = false
			bg_veil.visible = false
			if current_game_state == game_state.MainMenu and Globals.find_node("StartButton"):
				game_playing_ui.visible = false
				Globals.find_node("StartButton").grab_focus()
		menu_state.PauseMenu:
			Globals.find_node("ResumeButton").grab_focus()
			paused_ui.visible = true
			paused_content.visible = true
			options_ui.visible = false
			bg_veil.visible = true
			keybindings_menu.visible = false
		menu_state.OptionsMenu:
			Globals.find_node("keybindings_button").grab_focus()
			paused_ui.visible = true
			paused_content.visible = false
			options_ui.visible = true
			bg_veil.visible = true
			keybindings_menu.visible = false
		menu_state.KeybindingsMenu:
			Globals.find_node("keybinding_forward").grab_focus()
			paused_ui.visible = true
			paused_content.visible = false
			options_ui.visible = false
			bg_veil.visible = true
			keybindings_menu.visible = true

func restart_level()->void:
	get_tree().reload_current_scene()
	initialize_game_start()
func initialize_game_start()->void:
	game_progress.value = game_progress.max_value
	is_game_paused = false
	game_progress.tint_progress.r = 1.0
	game_progress.tint_progress.g = 1.0
	game_progress.tint_progress.b = 1.0
	game_progress.tint_progress.a = original_alpha
	game_over_ui.visible = false
	for child : AudioStreamPlayer3D in sound_man.get_children():  # remove all sounds
		child.free()
	intermission_timer = 1.0
	game_start_timer = default_game_start_time
	game_playing_timer = game_playing_time_max
	dev_man.money_made = 0.0
	dev_man.orders_delivered = 0
	dev_man.waiting_recipe_list.clear()
	dev_man.spawn_recipe_timer = dev_man.spawn_recipe_timer_max
	for child : Node in dev_man.orders_container.get_children():
		child.free()
	
	if not seen_tut:
		current_game_state = game_state.Tutorial
		seen_tut = true
		PlayerPrefs.set_pref("seen_tutorial", seen_tut)
		PlayerPrefs.save_data()
		return
	if seen_tut:
		current_game_state = game_state.WaitingToStart 

func _on_go_to_main_menu_button_up() -> void:
	current_game_state = game_state.MainMenu
	toggle_pause_game()
	get_tree().change_scene_to_file(main_menu_scene)
	update_current_menu_state()

func _on_options_button_button_up() -> void:
	current_menu_state = menu_state.OptionsMenu
	update_current_menu_state()

func _on_resume_button_button_up() -> void:
	toggle_pause_game()
	update_current_menu_state()

func _on_back_button_button_up() -> void:
	if current_game_state != game_state.MainMenu or current_menu_state == menu_state.KeybindingsMenu:
		current_menu_state -= 1
		update_current_menu_state()
	else: 
		current_menu_state = menu_state.NONE
		update_current_menu_state()
		Globals.find_node("StartButton").grab_focus()


func _on_reset_prefs_button_button_up() -> void:
	PlayerPrefs.delete_all()
	sound_man.music_volume = 0.6
	sound_man.sfx_volume = 0.6
	seen_tut = false
	PlayerPrefs.set_pref("seen_tutorial", seen_tut)
	sound_man.change_music_volume()
	sound_man.change_sfx_volume()
	PlayerPrefs.load_data()
	PlayerPrefs.save_data()
