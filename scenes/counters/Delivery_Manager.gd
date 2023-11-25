class_name DeliveryManager extends Node

@export_subgroup("Delivery_Counter")
@export var ingredient_scene_template : PackedScene
@export var order_scene : PackedScene
@onready var orders_container : BoxContainer = get_node("CanvasLayer/MarginContainer/VBoxContainer/Orders_Root/MarginContainer/orders_container")
@onready var waiting_recipe_list : Array[RecipeSO]
@export var possible_orders : recipe_list_so
@onready var spawn_recipe_timer : float = 0.0
@export var spawn_recipe_timer_max : float = 4.0
@export var orders_max : int = 4

#func time_timeout(parent)->void:
	#print("timeout")
	#for order in waiting_recipe_list:
		#if order.order_name == parent.get_parent().order_name:
			#hide_order_ui(order)
			#return
		#
		

func order_timeout(order_ui, order)->void:
	print(order.recipe_name," timed out")
	#print(order_ui)
	hide_order_ui(order)
	remove_order(order)
	return

func _process(delta: float) -> void:
	if waiting_recipe_list.size() < orders_max:
		spawn_recipe_timer -= delta
		if spawn_recipe_timer <= 0.0:
			give_new_order()

func give_new_order()->void:
	var index : int = randi_range (0, 3 )
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
			order_instance.order_name.text = waiting_recipe_so.recipe_name
			for ingredient in waiting_recipe_so.kitchen_object_so_list:
				var ing_icon = ingredient_scene_template.instantiate()
				order_instance.order_ingredients_container.add_child(ing_icon, true)
				ing_icon.Icon.texture = ingredient.Icon

func hide_order_ui(order)->void:
	var orders_ui := orders_container.get_children()
	for order_ui in orders_ui:
		if order_ui.order_name.text == order.recipe_name:
			order_ui.queue_free()
			return

func remove_order(order)->void:
	var first_occurence_of_order = waiting_recipe_list.find(order)
	waiting_recipe_list.erase(order)
	hide_order_ui(order)

func destroy_plate(plate)->void:
	plate.queue_free()

func try_deliver_recipe(plate : BaseFood)->void:
	for order in waiting_recipe_list:
		if order.kitchen_object_so_list.size() == plate.Ingredients.size():
			# has same number of ingredients
			for ingredient in order.kitchen_object_so_list: # cycle through all ingredients in order
				for plate_ingredient in plate.Ingredients: # cycle through all ingredients on plate
					if ingredient == plate_ingredient: # if both order and plate ingredients match
						# deliver the order
						print("Delivered ", order.recipe_name, "!")
						remove_order(order)
						destroy_plate(plate)
						return
	print("Not a requested recipe order!")
	return
	

