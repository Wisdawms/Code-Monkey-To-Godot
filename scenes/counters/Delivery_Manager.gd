class_name DeliveryManager extends Node

@export_subgroup("Delivery_Counter")
@export var ingredient_scene_template : PackedScene
@export var order_scene : PackedScene
@export var money_gained_scene : PackedScene
@onready var delivery_ui : MarginContainer = get_node("CanvasLayer/delivery_ui_container")
@onready var orders_container : BoxContainer = get_node("CanvasLayer/delivery_ui_container/VBoxContainer/Orders_Root/MarginContainer/orders_container")
@onready var waiting_recipe_list : Array[RecipeSO]
@export var possible_orders : recipe_list_so
@onready var spawn_recipe_timer : float = 4.0
@export var spawn_recipe_timer_max : float = 4.0
@export var orders_max : int = 4
@onready var orders_delivered : int = 0
@onready var money_made : float = 0.0
@onready var interacted_counter : BaseCounter

func get_formatted_money() -> String:
	var formatted_money: String = "$%.2f" % money_made
	return formatted_money

signal OrderDelivered
signal OrderFailed

func order_timeout(_order_ui : OrderClass, order:RecipeSO)->void:
	print(order.recipe_name," timed out")
	hide_order_ui(order)
	remove_order(order)
	return

func _process(delta: float) -> void:
	if game_man.is_game_playing():
		delivery_ui.visible = true
	elif not game_man.is_game_playing() or game_man.current_game_state == game_man.game_state.MainMenu: 
		delivery_ui.visible = false
	if game_man.current_game_state == game_man.game_state.GamePlaying:
		if waiting_recipe_list.size() < orders_max:
			spawn_recipe_timer -= delta
			if spawn_recipe_timer <= 0.0:
				give_new_order()

func give_new_order()->void:
	var index : int = randi_range (0, possible_orders.recipe_so_list.size() - 1 )
	spawn_recipe_timer = spawn_recipe_timer_max
	if possible_orders:
		if waiting_recipe_list.size() < orders_max:
			var waiting_recipe_so : RecipeSO = possible_orders.recipe_so_list[index]
			print_rich("[b] Order recieved: [", waiting_recipe_so.recipe_name,"]")
			waiting_recipe_list.append(waiting_recipe_so)
			var order_instance : OrderClass = order_scene.instantiate() as OrderClass
			var order_timer : Timer = order_instance.get_child(-1) as Timer
			order_timer.timeout.connect(order_timeout.bind(order_instance, waiting_recipe_so))
			orders_container.add_child(order_instance, true)
			order_instance.order_name.text = waiting_recipe_so.recipe_name # setting order name
			order_instance.order_price.text = "$%.2f" % waiting_recipe_so.price # setting price text
			#setting timer according to order givend
			var time_to_order : float = waiting_recipe_so.order_time
			order_instance.order_time.wait_time = time_to_order
			order_instance.order_time.start()
			# setting ingredient icons
			for ingredient in waiting_recipe_so.kitchen_object_so_list:
				var ing_icon := ingredient_scene_template.instantiate()
				order_instance.order_ingredients_container.add_child(ing_icon, true)
				ing_icon.Icon.texture = ingredient.Icon

func hide_order_ui(order : RecipeSO)->void:
	var orders_ui := orders_container.get_children()
	for order_ui in orders_ui:
		if order_ui.order_name.text == order.recipe_name:
			order_ui.queue_free()
			return

func remove_order(order : RecipeSO)->void:
	waiting_recipe_list.erase(order)
	hide_order_ui(order)

func destroy_plate(plate : BaseFood)->void:
	plate.queue_free()

func try_deliver_recipe(plate : BaseFood)->bool:
	if game_man.is_game_playing():
		for order in waiting_recipe_list: # cycle through the recieved orders
			if arrays_have_same_content(plate.Ingredients, order.kitchen_object_so_list): # cycle through all ingredients in the recieved order
				# deliver the order
				print("Delivered ", order.recipe_name, "!")
				money_made += order.price
				print_rich("[font_size=16][b][color=TEAL ]This [color=TOMATO]", order.recipe_name, "[color=TEAL ] cost [color=WEB_GREEN]$", "%.2f"%order.price ,". \n[color=TEAL ]You made [color=TOMATO]",get_formatted_money(), "[color=TEAL ] so far!")
				remove_order(order)
				destroy_plate(plate)
				var curr_counter : BaseCounter = Globals.find_node("Player").current_counter
				if curr_counter.type == "Delivery_Counter":
					curr_counter.order_price.text = "$%.2f" % order.price
					curr_counter.deliver_anim.play("delivered")
				orders_delivered += 1
				OrderDelivered.emit()
				return true
		print("Not a requested recipe order!")
		OrderFailed.emit()
		return false
	return false


func arrays_have_same_content(array1 : Array, array2 : Array)->bool:
	if array1.size() != array2.size(): return false
	for item : Object in array1:
		if !array2.has(item): return false
		if array1.count(item) != array2.count(item): return false
	return true
