class_name OrderClass extends MarginContainer

@onready var order_name : Label = get_node("VBoxContainer/order_name_time/order_name")
@onready var order_ingredients_container = get_node("VBoxContainer/order_ingredients")
@onready var order_time : Timer = get_node("order_time")
@onready var prog_bar : TextureProgressBar = get_node("VBoxContainer/order_name_time/circular-progress-bar")

func _process(delta: float) -> void:
	if order_time.time_left > 0.0:
		prog_bar.value = (order_time.time_left / order_time.wait_time) * prog_bar.max_value
	if order_time.time_left < 7:
		prog_bar.tint_progress = Color.RED
	else:
		prog_bar.tint_progress = Color.WHITE
