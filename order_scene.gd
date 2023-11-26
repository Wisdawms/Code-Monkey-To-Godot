class_name OrderClass extends MarginContainer

@onready var order_name : Label = get_node("VBoxContainer/order_name_time/order_name")
@onready var order_ingredients_container = get_node("VBoxContainer/order_ingredients")
@onready var order_time : Timer = get_node("order_time")
@onready var prog_bar : TextureProgressBar = get_node("VBoxContainer/order_name_time/circular-progress-bar")
var flickering_timer : float = 0.0
var flickering_interval : float = 0.2
@onready var original_alpha: float = prog_bar.tint_progress.a

func _ready() -> void:
	original_alpha = prog_bar.tint_progress.a

func _process(delta: float) -> void:
	if order_time.time_left > 0.0:
		prog_bar.value = (order_time.time_left / order_time.wait_time) * prog_bar.max_value
	if order_time.time_left <  order_time.wait_time * .35 :
		prog_bar.tint_progress.r = 1.0
		prog_bar.tint_progress.g = 0.0
		prog_bar.tint_progress.b = 0.0
		flash(delta)
	else:
		prog_bar.tint_progress.r = 1.0
		prog_bar.tint_progress.g = 1.0
		prog_bar.tint_progress.b = 1.0

func flash(delta)->void:
	flickering_timer += delta
	if flickering_timer >= flickering_interval:
		flickering_timer = 0.0
		toggle_visibility()
		
func toggle_visibility()->void:
	if prog_bar.tint_progress.a == original_alpha:
		prog_bar.tint_progress.a = 0.0
	else:
		prog_bar.tint_progress.a = original_alpha
