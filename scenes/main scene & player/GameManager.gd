class_name GameManager extends Node

@onready var dev_man : DeliveryManager = Globals.find_node("DeliveryManager") as DeliveryManager
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
@onready var music_volume_button: Button = get_node("CanvasLayer/options_ui/VBoxContainer/music_volume_button")
@onready var sound_effects_volume_button: Button = get_node("CanvasLayer/options_ui/VBoxContainer/sound_effects_volume_button")
@export var main_menu_scene : String = "res://scenes/main_menu_scene.tscn"


var orig_progress_alpha : float
var orig_under_alpha : float

signal StateChanged
signal OnGamePaused
signal OnGameUnpaused

enum game_state {
	WaitingToStart,
	CountdownToStart,
	GamePlaying,
	GameOver,
}

@onready var is_game_paused : bool = false
@onready var current_game_state : game_state = game_state.WaitingToStart
@export var waiting_to_start_timer : float = 1.0
@export var countdown_to_start_timer : float = 3.0
@export var game_playing_time_max : float = 10.0
@onready var game_playing_timer : float
@onready var once : bool = true
@onready var original_alpha:float = game_progress.tint_progress.a
var flickering_timer : float = 0.0
var flickering_interval : float = 0.2

func _process(delta: float) -> void:
	if is_game_playing() and not is_game_paused:
		bg_veil.visible = false
		if is_game_almost_over():
			if game_progress.tint_progress != Color.RED :
				game_progress.tint_progress.r = 1.0
				game_progress.tint_progress.g = 0.0
				game_progress.tint_progress.b = 0.0
			flash(delta)
	elif is_game_paused or not is_game_playing(): bg_veil.visible = true
	match current_game_state:	
		game_state.WaitingToStart:
			waiting_to_start_timer -= delta
			if waiting_to_start_timer < 0.0:
				current_game_state = game_state.CountdownToStart
				game_playing_ui.visible = true
				StateChanged.emit()
		game_state.CountdownToStart:
			countdown_to_start_timer -= delta
			if countdown_to_start_timer < 0.0:
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

	if countdown_timer_text.text != str(ceil(countdown_to_start_timer)):
		countdown_timer_text.text = str(ceil(countdown_to_start_timer))

func is_game_playing()->bool:
	return current_game_state == game_state.GamePlaying
func is_countdown_to_start()->bool:
	return current_game_state == game_state.CountdownToStart
func is_game_starting()->bool:
	return current_game_state == game_state.WaitingToStart
func is_game_over()->bool:
	return current_game_state == game_state.GameOver

func _ready() -> void:
	orig_progress_alpha = game_progress.tint_progress.a
	orig_under_alpha = game_progress.tint_under.a
	OnGamePaused.connect(show_pause_ui)
	OnGameUnpaused.connect(hide_pause_ui)
	StateChanged.connect(update_game_manager_ui)
	countdown_timer_text.visible = false
	game_over_ui.visible = false
	game_playing_ui.visible = false
	paused_ui.visible = false
	
func update_game_manager_ui()->void:
	if is_game_starting():
		game_starting_text.visible = true
	else: game_starting_text.visible = false
	if is_countdown_to_start():
		countdown_timer_text.visible = true
	else: countdown_timer_text.visible = false
	if is_game_over():
		game_over_ui.visible = true
		if gameover_recipes_number.text != str(dev_man.orders_delivered):
			gameover_recipes_number.text = str(dev_man.orders_delivered)
		if gameover_money_made.text != dev_man.get_formatted_money():
			gameover_money_made.text = dev_man.get_formatted_money()
	else: game_over_ui.visible = false

func is_game_almost_over()->bool:
	return game_playing_timer < game_playing_time_max * .30

func flash(delta)->void:
	flickering_timer += delta
	if flickering_timer >= flickering_interval:
		flickering_timer = 0.0
		toggle_visibility()
		
func toggle_visibility()->void:
	if game_progress.tint_progress.a == 0.0:
		game_progress.tint_progress.a = original_alpha
	else:
		game_progress.tint_progress.a = 0.0

# this is faster, because it doesn't run every frame
func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_ESCAPE:
			toggle_pause_game()

func toggle_pause_game()->void:
	is_game_paused = !is_game_paused
	if is_game_paused and Engine.time_scale != 0.0:
		Engine.time_scale = 0.0
		OnGamePaused.emit()
		if is_game_starting() or is_countdown_to_start() and game_starting_ui.visible != false:
			game_starting_ui.visible = false
			game_progress.tint_progress.a = 0.0
			game_progress.tint_under.a = 0.0
		if is_game_over() and game_over_ui.visible != false:
			game_over_ui.visible = false
	else:
		Engine.time_scale = 1.0
		OnGameUnpaused.emit()
		if is_game_starting() or is_countdown_to_start() and game_starting_ui.visible != true:
			game_starting_ui.visible = true
			game_progress.tint_progress.a = 0.59
			game_progress.tint_under.a = 0.33
		if is_game_over() and game_over_ui.visible != true:
			game_over_ui.visible = true

func show_pause_ui()->void:
	paused_ui.visible = true
	bg_veil.visible = true
func hide_pause_ui()->void:
	paused_ui.visible = false
	bg_veil.visible = false



func _on_go_to_main_menu_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_scene)


func _on_resume_button_pressed() -> void:
	toggle_pause_game()
