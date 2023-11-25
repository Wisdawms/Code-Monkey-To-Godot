extends TextureProgressBar

@onready var order_time : Timer = $"../../../order_time" as Timer

func _process(delta: float) -> void:
	if order_time.time_left > 0.0:
		value = (order_time.time_left / order_time.wait_time) * max_value
