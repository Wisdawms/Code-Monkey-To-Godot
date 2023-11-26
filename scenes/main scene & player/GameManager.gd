class_name GameManager extends Node

@onready var dev_man : DeliveryManager = Globals.find_node("DeliveryManager") as DeliveryManager
@onready var bg_veil : ColorRect = get_node("CanvasLayer/bg_veil")
@onready var countdown_timer_text : Label = get_node("CanvasLayer/countdown_timer_text")
@onready var game_starting_text : Label = get_node("CanvasLayer/game_starting_text")
@onready var game_over_ui : Control = get_node("CanvasLayer/game_over_ui")
@onready var gameover_recipes_number : Label = get_node("CanvasLayer/game_over_ui/gameover_recipes_number")
@onready var game_progress : TextureProgressBar = get_node("CanvasLayer/game_playing_ui/game_progress")
@onready var game_playing_ui : MarginContainer = get_node("CanvasLayer/game_playing_ui")
signal StateChanged

enum game_state {
	WaitingToStart,
	CountdownToStart,
	GamePlaying,
	GameOver
}

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
	if is_game_playing():
		if is_game_almost_over():
			if game_progress.tint_progress != Color.RED :
				game_progress.tint_progress.r = 1.0
				game_progress.tint_progress.g = 0.0
				game_progress.tint_progress.b = 0.0
			flash(delta)
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
	StateChanged.connect(update_game_manager_ui)
	countdown_timer_text.visible = false
	game_over_ui.visible = false
	game_playing_ui.visible = false
	
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
	else: game_over_ui.visible = false

func is_game_almost_over()->bool:
	return game_playing_timer < game_playing_time_max * .35

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
