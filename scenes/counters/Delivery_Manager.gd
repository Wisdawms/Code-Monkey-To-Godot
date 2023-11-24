class_name DeliveryManager extends Node


@onready var waiting_recipe_list : Array[RecipeSO]
@export var possible_orders : recipe_list_so
@onready var spawn_recipe_timer : float = 0.0
@export var spawn_recipe_timer_max : float = 4.0
@export var orders_max : int = 4

func _process(delta: float) -> void:
	spawn_recipe_timer -= delta
	if spawn_recipe_timer <= 0.0:
		var index : int = randi_range (0, 3 )
		spawn_recipe_timer = spawn_recipe_timer_max
		if possible_orders:
			if waiting_recipe_list.size() < orders_max:
				var waiting_recipe_so : RecipeSO = possible_orders.recipe_so_list[index]
				print(waiting_recipe_so.recipe_name)
				waiting_recipe_list.append(waiting_recipe_so)

func deliver_recipe(plate : BaseFood)->void:
	for order in waiting_recipe_list:
		if order.kitchen_object_so_list.size() == plate.Ingredients.size():
			# has same number of ingredients
			for ingredient in order.kitchen_object_so_list: # cycle through all ingredients in order
				for plate_ingredient in plate.Ingredients: # cycle through all ingredients on plate
					if ingredient == plate_ingredient: # if both order and plate ingredients match
						# deliver the order
						print("Delivered ", order.recipe_name, "!")
						plate.queue_free()
						waiting_recipe_list.erase(order) # erase order from list, as it is done
						return
