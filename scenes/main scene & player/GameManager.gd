class_name GameManager extends Node
@onready var bg_veil : ColorRect = get_node("CanvasLayer/bg_veil")
@onready var countdown_timer_text : Label = get_node("CanvasLayer/countdown_timer_text")
@onready var game_starting_text : Label = get_node("CanvasLayer/game_starting_text")
@onready var game_over_text : Label = get_node("CanvasLayer/game_over_text")
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
@export var game_playing_timer : float = 10.0

func _process(delta: float) -> void:
	match current_game_state:	
		game_state.WaitingToStart:
			waiting_to_start_timer -= delta
			if waiting_to_start_timer < 0.0:
				current_game_state = game_state.CountdownToStart
				StateChanged.emit()
		game_state.CountdownToStart:
			countdown_to_start_timer -= delta
			if countdown_to_start_timer < 0.0:
				current_game_state = game_state.GamePlaying
				StateChanged.emit()
		game_state.GamePlaying:
			game_playing_timer -= delta
			if game_playing_timer < 0.0:
				current_game_state = game_state.GameOver
				StateChanged.emit()
		game_state.GameOver:
			StateChanged.emit()

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
	game_over_text.visible = false
	
func update_game_manager_ui()->void:
	if is_game_starting():
		game_starting_text.visible = true
	else: game_starting_text.visible = false
	if is_countdown_to_start():
		countdown_timer_text.visible = true
	else: countdown_timer_text.visible = false
	if is_game_over():
		game_over_text.visible = true
	else: game_over_text.visible = false
