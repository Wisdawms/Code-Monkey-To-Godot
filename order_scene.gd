class_name OrderClass extends MarginContainer

@onready var order_name : Label = get_node("VBoxContainer/order_name_time/order_name")
@onready var order_ingredients_container = get_node("VBoxContainer/order_ingredients")
@onready var order_time : Timer = get_node("order_time")
